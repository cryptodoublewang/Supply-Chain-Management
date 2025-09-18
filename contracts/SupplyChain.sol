// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SupplyChain {
    address public owner;  // Contract owner

    constructor() {
        owner = msg.sender;  // Set deployer as owner
    }

    // Modifier to allow only the owner to execute certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Transfer ownership to another address (if needed)
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    // Enum to represent different supply chain stages
    enum Stage {
        Ordered,
        RawMaterialSupplied,
        Manufactured,
        Distributed,
        Retail,
        Sold
    }

    // Enum to represent shipment status
    enum ShipmentStatus {
        Pending,
        InTransit,
        Delivered
    }

    // Structure to store details of a material
    struct Material {
        uint256 id;
        string name;
        string description;
        address supplier;
        address manufacturer;
        address distributor;
        address retailer;
        Stage stage;
    }

    // Structure for supply chain participants
    struct Participant {
        address addr;
        string name;
        string location;
    }

    // Structure for shipment tracking
    struct Shipment {
        uint256 materialId;
        address sender;
        address receiver;
        string trackingId;
        ShipmentStatus status;
    }

    // Structure for transaction tracking
    struct Transaction {
        uint256 materialId;
        address participant;
        string action;
        uint256 timestamp;
    }

    // Mappings to store data
    mapping(uint256 => Material) public materials;
    mapping(address => Participant) public suppliers;
    mapping(address => Participant) public manufacturers;
    mapping(address => Participant) public distributors;
    mapping(address => Participant) public retailers;
    mapping(string => Shipment) public shipments;
    Transaction[] public transactions;

    // Counters to assign unique IDs
    uint256 public materialCounter;

    // Events
    event MaterialAdded(uint256 indexed materialId, string name);
    event ParticipantAdded(address indexed participant, string role);
    event MaterialStageUpdated(uint256 indexed materialId, Stage newStage);
    event ShipmentCreated(uint256 indexed materialId, string trackingId);
    event ShipmentUpdated(string trackingId, ShipmentStatus status);
    event TransactionRecorded(uint256 indexed materialId, string action, address participant);

    // Add new material (only owner)
    function addMaterial(string memory _name, string memory _description) public onlyOwner {
        materialCounter++;
        materials[materialCounter] = Material(
            materialCounter,
            _name,
            _description,
            address(0),  // No supplier assigned yet
            address(0),  // No manufacturer assigned yet
            address(0),  // No distributor assigned yet
            address(0),  // No retailer assigned yet
            Stage.Ordered
        );

        emit MaterialAdded(materialCounter, _name);
    }

    // Register supply chain participants (only owner)
    function addSupplier(address _addr, string memory _name, string memory _location) public onlyOwner {
        suppliers[_addr] = Participant(_addr, _name, _location);
        emit ParticipantAdded(_addr, "Supplier");
    }

    function addManufacturer(address _addr, string memory _name, string memory _location) public onlyOwner {
        manufacturers[_addr] = Participant(_addr, _name, _location);
        emit ParticipantAdded(_addr, "Manufacturer");
    }

    function addDistributor(address _addr, string memory _name, string memory _location) public onlyOwner {
        distributors[_addr] = Participant(_addr, _name, _location);
        emit ParticipantAdded(_addr, "Distributor");
    }

    function addRetailer(address _addr, string memory _name, string memory _location) public onlyOwner {
        retailers[_addr] = Participant(_addr, _name, _location);
        emit ParticipantAdded(_addr, "Retailer");
    }

    // Supply raw materials (Only Supplier)
    function supplyRawMaterials(uint256 _materialID) public {
        require(suppliers[msg.sender].addr != address(0), "Not a registered supplier");
        require(materials[_materialID].stage == Stage.Ordered, "Invalid stage");
        materials[_materialID].supplier = msg.sender;
        materials[_materialID].stage = Stage.RawMaterialSupplied;

        emit MaterialStageUpdated(_materialID, Stage.RawMaterialSupplied);
        recordTransaction(_materialID, "Raw Material Supplied", msg.sender);
    }

    // Manufacture material (Only Manufacturer)
    function manufactureMaterial(uint256 _materialID) public {
        require(manufacturers[msg.sender].addr != address(0), "Not a registered manufacturer");
        require(materials[_materialID].stage == Stage.RawMaterialSupplied, "Invalid stage");
        materials[_materialID].manufacturer = msg.sender;
        materials[_materialID].stage = Stage.Manufactured;

        emit MaterialStageUpdated(_materialID, Stage.Manufactured);
        recordTransaction(_materialID, "Manufactured", msg.sender);
    }

    // Distribute material (Only Distributor)
    function distributeMaterial(uint256 _materialID) public {
        require(distributors[msg.sender].addr != address(0), "Not a registered distributor");
        require(materials[_materialID].stage == Stage.Manufactured, "Invalid stage");
        materials[_materialID].distributor = msg.sender;
        materials[_materialID].stage = Stage.Distributed;

        emit MaterialStageUpdated(_materialID, Stage.Distributed);
        recordTransaction(_materialID, "Distributed", msg.sender);
    }

    // Retail material (Only Retailer)
    function retailMaterial(uint256 _materialID) public {
        require(retailers[msg.sender].addr != address(0), "Not a registered retailer");
        require(materials[_materialID].stage == Stage.Distributed, "Invalid stage");
        materials[_materialID].retailer = msg.sender;
        materials[_materialID].stage = Stage.Retail;

        emit MaterialStageUpdated(_materialID, Stage.Retail);
        recordTransaction(_materialID, "Available for Sale", msg.sender);
    }

    // Mark material as sold (Only assigned retailer)
    function sellMaterial(uint256 _materialID) public {
        require(materials[_materialID].retailer == msg.sender, "Not the assigned retailer");
        require(materials[_materialID].stage == Stage.Retail, "Invalid stage");
        materials[_materialID].stage = Stage.Sold;

        emit MaterialStageUpdated(_materialID, Stage.Sold);
        recordTransaction(_materialID, "Sold", msg.sender);
    }

    // Get current stage of material
    function getMaterialStage(uint256 _materialID) public view returns (string memory) {
        require(_materialID > 0 && _materialID <= materialCounter, "Invalid material ID");

        if (materials[_materialID].stage == Stage.Ordered) return "Ordered";
        if (materials[_materialID].stage == Stage.RawMaterialSupplied) return "Raw Material Supplied";
        if (materials[_materialID].stage == Stage.Manufactured) return "Manufactured";
        if (materials[_materialID].stage == Stage.Distributed) return "Distributed";
        if (materials[_materialID].stage == Stage.Retail) return "Retail";
        if (materials[_materialID].stage == Stage.Sold) return "Sold";

        return "Unknown";
    }

    // Create a shipment
    function createShipment(uint256 _materialID, address _receiver, string memory _trackingId) public {
        require(materials[_materialID].distributor == msg.sender, "Only distributor can create shipment");
        shipments[_trackingId] = Shipment(_materialID, msg.sender, _receiver, _trackingId, ShipmentStatus.Pending);

        emit ShipmentCreated(_materialID, _trackingId);
    }

    // Update shipment status
    function updateShipmentStatus(string memory _trackingId, ShipmentStatus _status) public {
        require(shipments[_trackingId].sender != address(0), "Shipment not found");
        shipments[_trackingId].status = _status;

        emit ShipmentUpdated(_trackingId, _status);
    }

    // Get transaction history
    function getTransactions() public view returns (Transaction[] memory) {
        return transactions;
    }

    // Record transaction
    function recordTransaction(uint256 _materialID, string memory _action, address _participant) internal {
        transactions.push(Transaction(_materialID, _participant, _action, block.timestamp));
        emit TransactionRecorded(_materialID, _action, _participant);
    }
}