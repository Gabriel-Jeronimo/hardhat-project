import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const QuotaManagerModule = buildModule("QuotaManagerModule", (m) => {
  // Default URI for the ERC1155 token metadata
  // You can override this when deploying by passing parameters
  const defaultUri = m.getParameter("uri", "https://api.example.com/metadata/{id}.json");

  // Deploy QuotaManager contract
  const quotaManager = m.contract("QuotaManager", [defaultUri]);

  return { quotaManager };
});

export default QuotaManagerModule;
