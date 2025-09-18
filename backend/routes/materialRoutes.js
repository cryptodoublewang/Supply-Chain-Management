const express = require("express");
const {
  addMaterial,
  getAllMaterials,
  getMaterialHistory,
  getMaterialStage,
} = require("../controllers/materialController");

const router = express.Router();

router.post("/add", addMaterial);
router.get("/", getAllMaterials);
router.get("/:id/history", getMaterialHistory);
router.get("/:id/stage", getMaterialStage);

module.exports = router;