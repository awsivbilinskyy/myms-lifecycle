#!/bin/bash
vagrant destroy --parallel
rm -rf ./.vagrant
rm -rf ./registry
rm -rf ./registry-mirror