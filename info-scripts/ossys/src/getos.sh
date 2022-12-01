## This code try to get system operative name

platform='unknown'
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
     platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
     platform='freebsd'
fi

echo $platform
## In case of linux systems


## In case of mac os systems

## 