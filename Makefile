# TODO: Test this
create:
	cd scripts && ./create-docker-machine.sh
	cd scripts && ./build-images.sh
	cd scripts && ./build-jars.sh

build:
	cd scripts && ./start-docker-machine.sh
	cd scripts && ./build-images.sh
	cd scripts && ./build-jars.sh

start:
	cd scripts && ./start-docker-machine.sh
	cd scripts && ./wait-until-container-up.sh
	cd scripts && ./curl-kafka-connect.sh
	cd scripts && ./run-sentiment-analysis.sh
	cd scripts && ./flask-entrypoint.sh

stop:
	cd scripts && ./stop-docker-machine.sh
