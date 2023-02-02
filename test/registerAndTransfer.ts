import { AptosClient, Types, HexString, AptosAccount } from "aptos";
import { getErrorMessage } from "./utils";

async function registerCoin(
  moduleAddress: string,
  coinTypeAddress: string,
  coinType: string
): Promise<{ msg: string; success: boolean }> {
  try {
    const coinTypeAddressHex = new HexString(coinTypeAddress);
    const payload: Types.TransactionPayload = {
      type: "entry_function_payload",
      function: `${moduleAddress}::genie::register_and_transfer_coin`,
      type_arguments: [`${coinTypeAddressHex.hex()}::${coinType}`],
      arguments: [100],
    };

    const response = await this.wallet.signAndSubmitTransaction(payload);
    await this.aptosClient.waitForTransaction(response?.hash || "");

    return {
      msg: `https://explorer.aptoslabs.com/txn/${response?.hash}`,
      success: true,
    };
  } catch (err) {
    const msg = getErrorMessage(err);
    return { msg: msg, success: false };
  }
}
