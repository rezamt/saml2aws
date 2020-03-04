#!/bin/bash

function verify_tools {
  echo "Checking required tools..."
  TOOLLIST="curl go make"

  export GOPATH=$PWD/go
  echo "GOPATH=$GOPATH"

  export PATH="$PATH:${GOPATH}/bin"
  echo "PATH=$PATH"

  for TOOL in `echo $TOOLLIST`
  do
    which $TOOL 1>/dev/null 2>&1
    if [[ $? -ne "0" ]]
       then echo "$TOOL not found - please install." && exit 1
    fi
  done
  echo -e " OK"
  return 0
}

function install_go {
    echo -n "Downloading golang package"
    GO_PACKAGE_URL='https://dl.google.com/go/go1.14.linux-amd64.tar.gz'
    GO_PACKAGE='go1.14.linux-amd64.tar.gz'

    curl -o ./go1.14.linux-amd64.tar.gz $GO_PACKAGE_URL

    if [[ $? -ne "0" ]] ; then
       echo -e "Failed to Download Golang binaries from $GO_PACKAGE_URL" && exit 1
    fi
    echo -e "Goland binaries successfully downloaded"


    echo -e "Extracting go package $GO_PACKAGE to go"

    tar -xvf $GO_PACKAGE
    if [[ $? -ne "0" ]] ; then
       echo -e "Failed to Download Golang binaries from $GO_PACKAGE_URL" && exit 1
    fi
    echo -e "Goland package successfully installed"

    PROJECT_WORKSPACE=$PWD/.go
    echo -e "Creating project workspace: $PROJECT_WORKSPACE"
    mkdir -p $PROJECT_WORKSPACE

    return 0
}


function build_saml2aws() {
  export GOPATH=$PWD/.go
  echo "GOPATH=$GOPATH"

  export PATH="$PATH:${GOPATH}/bin"
  echo "PATH=$PATH"

  mkdir -p $GOPATH/src/github.com/versent

  pushd $GOPATH/src/github.com/versent

  git clone $GIT_REPO

  pushd saml2aws

  echo "Building SAML2AWS Code"

  make mod
  make install
}

source "./jenkins.vars"

case "$1" in
    install)
      install_go
        ;;

    build)
      build_saml2aws
        ;;

    verify)
      verify_tools
        ;;

    *)
    echo "Usage:" >&2
    echo "./jenkins install-go            Installing golang into your build environment"
    echo "./jenkins build                 Build saml2aws"
    echo "./jenkins verify                Checking golang installed"
    RETVAL=2
    ;;
esac

exit $RETVAL