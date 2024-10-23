import { LightningElement } from 'lwc';
import { subscribe, unsubscribe, onError, isEmpEnabled } from 'lightning/empApi';

/**
 * @typedef {Object} DebugLog
 * @property {DebugLogData} data
 * @property {string} channel
 */

/**
 * @typedef {Object} DebugLogData
 * @property {string} schema
 * @property {DebugLogPayload} payload
 * @property {{ "replayId": number }} event
 */

/**
 * @typedef {Object} DebugLogPayload
 * @property {string} CreatedById
 * @property {string} CreatedDate
 * @property {string} Message__c
 * @property {string} Stack__c
 */

const columns = [
  {
    type: 'date',
    fieldName: 'CreatedDate',
    label: 'Created',
    initialWidth: 175,
    typeAttributes: {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    }
  },
  // TODO: make a column for each field based on your metadata
  {
    type: 'text',
    fieldName: 'Apex_Trigger__c', // TODO
    label: 'Apex Trigger' // TODO
  },
  {
    type: 'text',
    fieldName: 'replayId', // TODO
    label: 'ReplayID' // TODO
  },
  {
    type: 'integer',
    fieldName: 'Batch_Size__c',// TODO
    label: 'Batch Size' // TODO
  },
  {
    type: 'text',
    fieldName: 'Last_Error__c', // TODO
    label: 'Last Error' // TODO
  },
  {
    type: 'integer',
    fieldName: 'Retries__c',// TODO
    label: 'Retries' // TODO
  },
  {
    type: 'text',
    fieldName: 'Topic__c', // TODO
    label: 'Topic' // TODO
  },
  {
    type: 'integer',
    fieldName: 'Position__c',// TODO
    label: 'Position' // TODO
  }
];

export default class DebugLogViewer extends LightningElement {
  channelName = '/event/Subscriber_Telemetry__e'; // TODO
  isSubscribeEnabled = false;
  isUnsubscribeEnabled = !this.isSubscribeEnabled;

  subscription = {};
  empEnabled = true;

  logs = [];
  columns = columns;

  get buttonVariant() {
    return this.isSubscribeEnabled ? 'neutral' : 'brand';
  }

  get buttonLabel() {
    return this.isSubscribeEnabled ? 'Unsubscribe' : 'Subscribe';
  }

  // Tracks changes to channelName text field
  handleChannelName(event) {
    this.channelName = event.target.value;
  }

  // Initializes the component
  connectedCallback() {
    // Register error listener
    this.registerErrorListener();
    isEmpEnabled().then((empEnabled) => {
      this.empEnabled = empEnabled;
    });
  }

  disconnectedCallback() {
    this.handleUnsubscribe();
  }

  handleToggleSubscribe() {
    if (!this.isSubscribeEnabled) {
      this.handleSubscribe();
    } else {
      this.handleUnsubscribe();
    }
  }

  // Handles subscribe button click
  handleSubscribe() {
    // Invoke subscribe method of empApi. Pass reference to messageCallback
    subscribe(this.channelName, -2, (/** @type {DebugLog} */ response) => {
      try {
        this.logs = [{ ...response.data.payload, replayId: response.data.event.replayId }, ...this.logs];
      } catch (ex) {
        console.log('Error parsing response: ', JSON.stringify(response));
      }
    }).then((response) => {
      // Response contains the subscription information on subscribe call
      console.log('Subscription request sent to: ', JSON.stringify(response.channel));
      this.subscription = response;
      this.toggleSubscribeButton(true);
    });
  }

  // Handles unsubscribe button click
  handleUnsubscribe() {
    this.toggleSubscribeButton(false);

    // Invoke unsubscribe method of empApi
    unsubscribe(this.subscription, (response) => {
      console.log('unsubscribe() response: ', JSON.stringify(response));
      // Response is true for successful unsubscribe
      this.logs = [];
    });
  }

  toggleSubscribeButton(enableSubscribe) {
    this.isSubscribeEnabled = enableSubscribe;
    this.isUnsubscribeEnabled = !enableSubscribe;
  }

  registerErrorListener() {
    // Invoke onError empApi method
    onError((error) => {
      console.log('Received error from server: ', JSON.stringify(error));
      // Error contains the server-side error
    });
  }
}