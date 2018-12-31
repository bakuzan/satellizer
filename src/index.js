import './styles/hover-data.css';
import './styles/accordion.css';
import './styles/main.css';
import { Elm } from './Main.elm';

export default Elm;

if (process.env.NODE_ENV === 'development') {
  console.log(
    '%c Your Elm App is running in development mode!',
    'color: maroon; font-size: 16px; font-weight: bold;'
  );
  Elm.Main.init({
    node: document.getElementById('satellizer'),
    flags: {
      contentType: 'anime',
      isAdult: false,
      activeTab: 'History',
      breakdownType: 'SEASON',
      detailGroup: '2018-04'
    }
  });
}
