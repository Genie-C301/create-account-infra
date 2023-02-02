FROM ubuntu:20.04
RUN apt update && apt-get upgrade -y && apt-get install python3 python3-pip curl jq -y
WORKDIR /home/genie
COPY . /home/genie
RUN chmod +x /home/genie/scripts/install-aptos.sh
RUN chmod +x /home/genie/scripts/create-account.sh
CMD ["./scripts/install-aptos.sh"]