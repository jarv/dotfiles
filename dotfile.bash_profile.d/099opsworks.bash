for env in /apollo/env/*; do
    export PATH=$PATH:${env}/bin;
done
export AWS_ACCOUNT_ID=johnjarv
eval "$(rbenv init -)"
