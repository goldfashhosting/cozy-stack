#!/usr/bin/env bash

go build
./cozy-stack serve &
sleep 5
./cozy-stack instances add --dev --passphrase cozytest localhost:8080

export CLIENT_ID=$(./cozy-stack instances client-oauth localhost:8080 http://localhost/ test github.com/cozy/cozy-stack/integration)
export TEST_TOKEN=$(./cozy-stack instances token-oauth localhost:8080 $CLIENT_ID io.cozy.pouchtestobject)

cd tests/pouchdb-integration
npm install && npm run test
testresult=$?
cd ../..

./scripts/build.sh assets
assetsresult=$?

pidstack=$(jobs -pr)
[ -n "$pidstack" ] && kill -9 "$pidstack"

if git grep -l -e 'github.com/labstack/gommon/log' -e 'github.com/dgrijalva/jwt-go' -- '*.go'; then
  exit 1
fi

[ $testresult -gt 0 ] && exit $testresult
[ $assetsresult -gt 0 ] && exit $assetsresult
