# Minimal, portable (POSIX awk: gawk / mawk / BSD awk) reader for registry/*.yaml.
#
# Supported YAML subset (everything the registry uses; anything else is an error):
#   - "key: value" lines, nested by indentation (any consistent indent width)
#   - values: "double quoted", 'single quoted', [flow, "lists"], or plain scalars
#   - whole-line comments and blank lines
#
# Usage: awk -v want=meta|section -v want_mode=dark|light -v section=NAME \
#            -f registry.awk FILE FILE        (FILE is passed twice: pass 1 finds
#                                              the theme's own `mode:`, pass 2 emits)
# Output: one "key<TAB>value" line per entry. Lists are emitted as compact JSON
# (["#ff9e64","bold"]), which is also valid YAML flow syntax.
#   want=meta     -> top-level scalars (name, mode, description, ...)
#   want=section  -> entries of `section`; for mode: adaptive themes the section is
#                    read from the `want_mode` (dark|light) sub-tree.

function fail(msg) {
  printf "registry: %s:%d: %s\n", FILENAME, FNR, msg > "/dev/stderr"
  failed = 1
  exit 2
}

function trim(s) {
  sub(/^[ ]+/, "", s)
  sub(/[ ]+$/, "", s)
  return s
}

# Convert a YAML flow list "[a, 'b', \"c\"]" to compact JSON.
function conv_list(s,    inner, n, i, c, q, tok, out, first, started) {
  if (substr(s, length(s), 1) != "]") fail("unterminated list: " s)
  inner = substr(s, 2, length(s) - 2)
  out = "["
  first = 1
  tok = ""
  q = ""
  started = 0
  n = length(inner)
  for (i = 1; i <= n + 1; i++) {
    c = (i <= n) ? substr(inner, i, 1) : ","
    if (q != "") {
      if (c == q) { q = "" } else { tok = tok c }
    } else if (c == "\"" || c == "'") {
      q = c; started = 1
    } else if (c == ",") {
      tok = trim(tok)
      if (started || tok != "") {
        if (!first) out = out ","
        gsub(/\\/, "\\\\", tok)
        gsub(/"/, "\\\"", tok)
        out = out "\"" tok "\""
        first = 0
      }
      tok = ""; started = 0
    } else {
      tok = tok c
    }
  }
  if (q != "") fail("unterminated quote in list: " s)
  return out "]"
}

function conv(s,    first, last) {
  first = substr(s, 1, 1)
  last = substr(s, length(s), 1)
  if (first == "\"") {
    if (length(s) < 2 || last != "\"") fail("unterminated double-quoted value: " s)
    s = substr(s, 2, length(s) - 2)
    gsub(/\\"/, "\"", s)
    return s
  }
  if (first == "'") {
    if (length(s) < 2 || last != "'") fail("unterminated single-quoted value: " s)
    s = substr(s, 2, length(s) - 2)
    gsub(/''/, "'", s)
    return s
  }
  if (first == "[") return conv_list(s)
  if (first == "{" || first == "|" || first == ">" || first == "&" || first == "*")
    fail("unsupported YAML value: " s)
  if (s ~ / #/) fail("trailing comment not supported: " s)
  return s
}

# Parse the current line into: depth, keys[0..depth-1], ind[], has_val, val.
# Returns 0 for blank/comment lines.
function parse_line(    line, indent, rest, key, after) {
  line = $0
  sub(/\r$/, "", line)
  if (line ~ /^[ ]*$/ || line ~ /^[ ]*#/) return 0
  if (line ~ /^[ ]*\t/) fail("tab indentation not supported")
  match(line, /^[ ]*/)
  indent = RLENGTH
  rest = substr(line, indent + 1)
  if (!match(rest, /^[A-Za-z0-9_]+:/)) fail("unsupported syntax: " rest)
  key = substr(rest, 1, RLENGTH - 1)
  after = substr(rest, RLENGTH + 1)
  if (after != "" && substr(after, 1, 1) != " ") fail("expected space after ':' in: " rest)
  after = trim(after)

  while (depth > 0 && ind[depth - 1] >= indent) depth--
  ind[depth] = indent
  keys[depth] = key
  depth++

  has_val = (after != "")
  val = has_val ? conv(after) : ""
  return 1
}

FNR == 1 { depth = 0 }

# ---- pass 1: learn the theme's own mode ------------------------------------
FNR == NR {
  if (parse_line() && depth == 1 && keys[0] == "mode" && has_val) docmode = val
  next
}

# ---- pass 2: emit -----------------------------------------------------------
{
  if (!parse_line()) next

  if (want == "meta") {
    if (depth == 1 && has_val) printf "%s\t%s\n", keys[0], val
    next
  }

  # want == "section"
  if (docmode == "adaptive") {
    if (depth >= 1 && keys[0] == want_mode) seen_mode = 1
    if (depth >= 2 && keys[0] == want_mode && keys[1] == section) {
      seen = 1
      if (depth == 3 && has_val) printf "%s\t%s\n", keys[2], val
      else if (depth > 3) fail("nesting deeper than supported under " section)
    }
  } else {
    if (depth >= 1 && keys[0] == section) {
      seen = 1
      if (depth == 2 && has_val) printf "%s\t%s\n", keys[1], val
      else if (depth > 2) fail("nesting deeper than supported under " section)
    }
  }
}

END {
  if (failed) exit 2
  if (want == "section") {
    if (docmode == "adaptive" && !seen_mode) {
      printf "registry: no '%s' variant in adaptive theme\n", want_mode > "/dev/stderr"
      exit 3
    }
    if (!seen) {
      printf "registry: no '%s' section\n", section > "/dev/stderr"
      exit 3
    }
  }
}
