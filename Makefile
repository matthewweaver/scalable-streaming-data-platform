# TODO: Test this
create:
	cd scripts && ./create-docker-machine.sh
	cd scripts && ./build-images.sh
	cd scripts && ./build-jars.sh

build:
	cd scripts && ./start-docker-machine.sh
	cd scripts && ./build-images.sh
	cd scripts && ./build-jars.sh

start: check-var-searchTerm
	cd scripts && ./start-docker-machine.sh
	# TODO: Only run curl once docker ps shows as started
	sleep 10
	cd scripts && ./curl-kafka-connect.sh
	cd scripts && ./run-sentiment-analysis.sh
	cd scripts && ./run-twitter-producer.sh $searchTerm

stop:
	cd scripts && ./stop-docker-machine.sh

# TODO: Test this
run: check-var-searchTerm create start

check-var-%:
	@ if [ "${${*}}" = "" ]; then echo "Environment variable $* not set"; exit 1; fi