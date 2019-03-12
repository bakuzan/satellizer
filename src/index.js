import './styles/hover-data.css';
import { Elm } from './Main.elm';

const themeOne = {
  baseBackground: 'ffffff',
  baseBackgroundHover: 'd9d9d9',
  baseColour: '000000',
  colour: '850512',
  contrast: '7e7e86',
  anchorColour: 'ce414a',
  anchorColourHover: 'e1e3ef',
  primaryBackground: '850512',
  primaryBackgroundHover: 'cf081c',
  primaryColour: 'e1e3ef'
};

const themeTwo = {
  baseBackground: '420309',
  baseBackgroundHover: '8b0613',
  baseColour: 'ffffff',
  colour: 'ce414a',
  contrast: 'e1e3ef',
  anchorColour: '7e7e86',
  anchorColourHover: '850512',
  primaryBackground: '850512',
  primaryBackgroundHover: 'cf081c',
  primaryColour: 'e1e3ef'
};

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
      activeTab: 'Airing',
      breakdownType: 'SEASON',
      detailGroup: '2018-04',
      theme: themeOne
    }
  });
}
