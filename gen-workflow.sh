#/bin/bash

cp .github/workflows/cosmic-greeter.yml .github/workflows/$1.yml
sed -i "s/cosmic-greeter/$1/g" .github/workflows/$1.yml

echo "Workflow $1.yml created"
