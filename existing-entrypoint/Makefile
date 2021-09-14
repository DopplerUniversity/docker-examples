build:
	docker image build -t doppleruniversity/custom-entrypoint .

run:
	docker container run --rm --name doppler -p 8080:8080 -e DOPPLER_TOKEN=$$DOPPLER_TOKEN doppleruniversity/custom-entrypoint $(CMD)
