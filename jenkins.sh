#!/bin/bash


source "./jenkins.vars"

case "$1" in
    install)
      echo "Installing golang version 1.14"
        ;;

    build)
      echo "Buidling saml2aws"
        ;;


    verify)
      echo "Checking environment settings"
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