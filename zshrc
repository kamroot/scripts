# Custom ZSH configurations
# add it with a line like [[ ! -f ~/code/scripts/zshrc ]] || source ~/code/scripts/zshrc
# in ~/.zshrc

## docker functions  
d.exec() { 
  if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit -1
  fi
	_pid=`docker ps  | grep $1 | awk ' { print $1 } '`
  echo "==> docker exec -ti $_pid $2"
	docker exec -ti $_pid $2
}

d.logs() { 
  if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit -1
  fi
	_pid=`docker ps  | grep $1 | awk ' { print $1 } '`
  echo "==> docker logs -f $_pid"
	docker logs -f $_pid
}

# Does not work 
d.remote.exec() {
  set -x
  echo "starting remote execution"
	_pid=`ssh -l ubuntu server docker ps  | grep $1 | awk ' { print $1 } '`
  echo "==> ssh -l ubuntu server docker exec -ti $_pid $2"
	ssh -l ubuntu server docker exec -i $_pid $2
}

