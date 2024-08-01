"use client";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import { ConnectBitcoin } from "@zetachain/universalkit";
import ProjectListItem from "../component/ProjectListItem";
import { useBitcoinWallet } from "@zetachain/universalkit";


export type ProjectItem = {
  name: string;
  description: string;
  image: string;
  target: number;
  raised: number;
  closeDate: string;
};

const Page = () => {

  const data: ProjectItem[] = [
    {
      name: "Pocket MICRO: Tribute to Classic Pocket Handhelds",
      description:
        "Helio G99 processor丨Borderless Full-Screen丨IPS True Color Screen丨CNC Aluminum Alloy Frame",
      image:
        "https://c3.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,g_center,q_auto,f_auto,h_312,w_312/ifnk3skrnif25i8k2vzw",
      target: 0.5,
      raised: 0.001,
      closeDate: "2022-12-31",
    },
    {
      name: "Litheli FrozenPack: The First Backpack Car Fridge",
      description:
        "Backpack design | -4℉ to 68℉ | 15 mins cooling | 77% larger packing space | 2 ways to power",
      image:
        "https://c4.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,g_center,q_auto,f_auto,h_312,w_312/maal1skvefqjqwwmkfl1",
      target: 1,
      raised: 0.001,
      closeDate: "2022-12-31",
    },
  ];
  const { address, loading, connectedWalletType, connectWallet, disconnect, sendTransaction } =
    useBitcoinWallet();
  return (
    <div className="m-4">
      <div className="flex justify-end gap-2 mb-10">
        <ConnectBitcoin />
        <ConnectButton
          label="Connect EVM"
          showBalance={false}
        />
      </div>
      <div className="flex items-center flex-col">
        <div className="w-[1200px]">
          <h1 className="text-4xl font-bold text-center mb-4">Fund by Bitcoin</h1>
          <div className="w-200"></div>
          <p className="text-center">
            "Fund by Bitcoin" is a crowdfunding platform enabling users to raise funds using Bitcoin
            via ZetaChain. The funds can be withdrawn across any blockchain, offering seamless
            cross-chain transactions for campaign organizers.
          </p>
          <div className="flex border border-sky-500 flex-col items-center py-4 my-4 gap-4">
            {data.map((project) => (
              <ProjectListItem
                key={project.name}
                project={project}
              />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Page;
