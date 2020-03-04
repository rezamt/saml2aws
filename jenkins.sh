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

function set_env {
  export GOPATH=$PWD/.go
  echo "GOPATH=$GOPATH"

  export PATH="$PATH:$PWD/go/bin"
  echo "PATH=$PATH"
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
  mkdir -p $GOPATH/src/github.com/versent

  echo -e "Adding GOPATH to PATH"
  DEFAULT_PATH=$PATH
  export PATH="$PATH:$GOPATH/bin"
  echo "PATH=$PATH"

  pushd $GOPATH/src/github.com/versent

  git clone $GIT_REPO

  pushd saml2aws


  echo -e "Current Build directory: $PWD"

  echo "# https://golang.org/doc/go1.13"
  echo "#  Users who cannot reach the default proxy and checksum database (for example, due to a firewalled or sandboxed configuration)"
  echo "#  may disable their use by setting GOPROXY to direct, and/or GOSUMDB to off. go env -w can be used to set the default"
  echo "#  values for these variables independent of platform:"
  echo "#  go env -w GOPROXY=direct"
  echo "#  go env -w GOSUMDB=off"

  go env -w GOPROXY=direct
  go env -w GOSUMDB=off

   echo "make prepare"
   make prepare

  export PATH=$DEFAULT_PATH
  echo -e "Current Directory: $PWD"
  echo -e "Curent PATH: $PATH"

  echo "make compile"
  make compile

}


function dist_saml2aws() {

  pushd $GOPATH/src/github.com/versent/saml2aws

  echo "Creating distribution package"
  echo "make dist"
  make dist

  popd

  echo "Moving distribution file to the project folder"
  mv $GOPATH/src/github.com/versent/saml2aws/dist ./dist

  ls -rtl ./dist
}


source "./jenkins.vars"

set_env

case "$1" in
    install)
      install_go
        ;;

    build)
      build_saml2aws
        ;;

    dist)
      dist_saml2aws
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