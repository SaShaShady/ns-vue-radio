import config from '../config'
import firebase from 'nativescript-plugin-firebase'

export class State {
  player = undefined
  playerScreen = 'LIVE'
  playPromise = undefined
  currentTab = config.sections[0]
  firebase = firebase
  foreground = true
  lastMessageId = 0
  connection = true
  language = 'en'
  sections = config.sections
  loadedLanguages = ['en', 'es', 'pt']
}
