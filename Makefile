-include .env
export

.PHONY: build run clean

build:
	@test -n "$(MODEL)" -a -n "$(PASSWORD)" -a -n "$(CODEWORD)" || (echo "Missing .env - run: cp .env.example .env" && exit 1)
	sed -e 's/{password}/$(PASSWORD)/g' -e 's/{codeword}/$(CODEWORD)/g' Modelfile > Modelfile.test
	ollama create $(MODEL) -f Modelfile.test

run:
	ollama run $(MODEL)

clean:
	rm -f Modelfile.test
	-ollama rm $(MODEL)
