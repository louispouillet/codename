-include .env
export

.PHONY: build run chat clean

build:
	@test -n "$(MODEL)" -a -n "$(PASSWORD)" -a -n "$(CODEWORD)" || (echo "Missing .env - run: cp .env.example .env" && exit 1)
	sed -e 's/{password}/$(PASSWORD)/g' -e 's/{codeword}/$(CODEWORD)/g' Modelfile > Modelfile.test
	ollama create $(MODEL) -f Modelfile.test

run:
	ollama run $(MODEL)

chat:
	@test -n "$(MSG)" || (echo 'Usage: make chat MSG="your message"' && exit 1)
	@./scripts/chat.sh $(MODEL) "$(MSG)"

clean:
	rm -f Modelfile.test
	-ollama rm $(MODEL)
