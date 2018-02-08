import './styles/hover-data.css';
import './styles/accordion.css';
import './styles/main.css';
import { Main } from './Main.elm';


export default Main;

if (process.env.NODE_ENV === "development") {
  console.log("%c Your Elm App is running in development mode!", "color: maroon; font-size: 16px; font-weight: bold;")
  Main.embed(document.getElementById("satellizer"), {
    contentType: "anime",
    isAdult: false,
  })
}
