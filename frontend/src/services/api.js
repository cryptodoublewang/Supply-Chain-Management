import axios from "axios";

const API_URL = import.meta.env.VITE_API_BASE_URL;

// Materials
export const addMaterial = (materialData) => axios.post(`${API_URL}/materials/add`, materialData);
export const getMaterials = () => axios.get(`${API_URL}/materials/`);
export const getMaterialHistory = (materialId) => axios.get(`${API_URL}/materials/${materialId}/history`);
export const getMaterialStage = (materialId) => axios.get(`${API_URL}/materials/${materialId}/stage`);

// Participants
export const addParticipant = (participantData) => axios.post(`${API_URL}/participants/add`, participantData);
export const getAllParticipants = () => axios.get(`${API_URL}/participants/`);

// Transactions
export const recordTransaction = (transactionData) => axios.post(`${API_URL}/transactions/add`, transactionData);
export const getTransactions = () => axios.get(`${API_URL}/transactions/`);

// Shipments
export const addShipment = (shipmentData) => axios.post(`${API_URL}/shipments/add`, shipmentData);
export const updateShipmentStatus = async (updateData) => {
    return await axios.post(`${API_URL}/shipments/update`, updateData, {
      headers: { "Content-Type": "application/json" },
    });
  };
export const getAllShipments = () => axios.get(`${API_URL}/shipments/`);