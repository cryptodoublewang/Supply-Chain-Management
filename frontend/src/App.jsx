import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import Home from "./pages/Home";
import Navbar from './components/Navbar';
import AddMaterial from './pages/AddMaterial';
import MaterialList from "./pages/MaterialList";
import Material from "./pages/MaterialDetails";
import Participants from "./pages/Participants";
import Transactions from "./pages/Transactions";
import Shipments from "./pages/Shipments";
import image from './assets/home.jpg';

function App() {
  return (
    <Router>
      <Navbar />
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/add-material" element={<AddMaterial />} />
            <Route path="/materials" element={<MaterialList />} />
            <Route path="/material-details" element={<Material />} />
            <Route path="/participants" element={<Participants />} />
            <Route path="/transactions" element={<Transactions />} />
            <Route path="/shipments" element={<Shipments />} />
          </Routes>
    </Router>
  );
}

export default App;