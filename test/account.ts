import { AptosAccount } from "aptos";

function hexToBytes(hex: string) {
  let bytes = [];
  for (let c = 0; c < hex.length; c += 2)
    //@ts-ignore
    bytes.push(parseInt(hex.substr(c, 2), 16));
  return bytes;
}

const getAccountAddress = () => {
  const account = new AptosAccount(
    Uint8Array.from(
      hexToBytes(
        "C13EC76463E58ABA752FA7B4376F48745F3F99FC6287C4E5EEEBF784819ACD78"
      )
    )
  );
  console.log(account.address());
};

getAccountAddress();
