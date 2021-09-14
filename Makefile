ubuntu-build:
	docker image build -t doppler/ubuntu -f ubuntu.Dockerfile .

ubuntu-run:
	docker container run --rm -it --name ubuntu-doppler doppler/ubuntu

alpine-build:
	docker image build -t doppler/alpine -f alpine.Dockerfile .

alpine-run:
	docker container run --rm -it --name alpine-doppler doppler/alpine

centos-build:
	docker image build -t doppler/centos -f centos.Dockerfile .

centos-run:
	docker container run --rm -it --name centos-doppler doppler/centos
