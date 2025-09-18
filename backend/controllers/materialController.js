const Material = require("../models/Material");
const Transaction = require("../models/Transaction");
const { web3js, contract } = require("../config/web3");

const ownerAddress = process.env.OWNER_ADDRESS;

if (!ownerAddress) {
  console.error("OWNER_ADDRESS is not defined in environment variables");
  process.exit(1);
}

exports.addMaterial = async (req, res) => {
  try {
    const { name, description, stage } = req.body;

    if (!name || !description) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const nonce = await web3js.eth.getTransactionCount(ownerAddress);
    const gasPrice = await web3js.eth.getGasPrice();

    const data = contract.methods.addMaterial(name, description, stage).encodeABI();

    const tx = {
      from: ownerAddress,
      to: contract.options.address,
      gas: 2000000,
      gasPrice: gasPrice,
      nonce: nonce,
      data: data,
    };

    const signedTx = await web3js.eth.accounts.signTransaction(tx, process.env.OWNER_PRIVATE_KEY);
    const receipt = await web3js.eth.sendSignedTransaction(signedTx.rawTransaction);

    const materialCounter = await contract.methods.materialCounter().call();

    const material = new Material({
      blockchainId: parseInt(materialCounter),
      name,
      description,
      stage: stage || "Ordered",
    });

    await material.save();

    const transaction = new Transaction({
      materialId: material.blockchainId,
      participant: ownerAddress,
      action: "MEDICINE_CREATED",
      transactionHash: receipt.transactionHash,
      details: { material: material._id },
      timestamp: Date.now()
    });

    await transaction.save();

    res.status(201).json({ message: "Material added successfully", material, transaction });

  } catch (error) {
    console.error("Error adding material:", error);
    res.status(500).json({ error: error.message });
  }
};

exports.getAllMaterials = async (req, res) => {
  try {
    const materials = await Material.find();
    res.json(materials);
  } catch (error) {
    console.error("Error fetching materials:", error);
    res.status(500).json({ error: "Error fetching materials" });
  }
};

exports.getMaterialHistory = async (req, res) => {
  try {
    const transactions = await Transaction.find({ materialId: req.params.id }).sort({ timestamp: -1 });
    res.json(transactions);
  } catch (error) {
    res.status(500).json({ error: "Error fetching material history" });
  }
};

exports.getMaterialStage = async (req, res) => {
  try {
    const materialId = req.params.id;

    if (!materialId) {
      return res.status(400).json({ error: "Material ID is required" });
    }

    const materialIdNum = parseInt(materialId);

    if (isNaN(materialIdNum)) {
      return res.status(400).json({ error: "Invalid Material ID" });
    }

    const stage = await contract.methods.getMaterialStage(materialIdNum).call();
    res.json({ materialId: materialIdNum, stage });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error fetching material stage", details: error.message });
  }
};