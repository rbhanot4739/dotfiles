test -z $DEVBOX_COREPACK_ENABLED || corepack enable --install-directory "/Users/rbhanot/.local/share/devbox/global/default/.devbox/virtenv/nodejs/corepack-bin/"
test -z $DEVBOX_COREPACK_ENABLED || export PATH="/Users/rbhanot/.local/share/devbox/global/default/.devbox/virtenv/nodejs/corepack-bin/:$PATH"
echo 'Welcome to devbox!' > /dev/null