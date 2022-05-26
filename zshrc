# Custom ZSH configurations
# add it with a line like [[ ! -f ~/code/scripts/zshrc ]] || source ~/code/scripts/zshrc
# in ~/.zshrc

## docker functions  
docker_exec() { 
	_pid=`docker ps  | grep $1 | awk ' { print $1 } '`
	docker exec -ti $_pid $2
	echo "==> docker exec -ti $_pid $2"
}

