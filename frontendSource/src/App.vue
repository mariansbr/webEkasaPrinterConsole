<script lang="ts">
//import { defineComponent } from "vue";
const dev = true;
export default {
  setup() {

  },
  data() {
    return {
      ekasaSet: false,
      scannerSet: false,
      settings: {
        ekasa: {},
        scanner: {}
      } as any,
      ekasaTyps: [
        { id: 0, name: "Nepoužívať" },
        { id: 1, name: "MRP eKasa 8000" },
        { id: 2, name: "Fiskal PRO" },
        { id: 3, name: "Elcom Efox" },
        { id: 4, name: "Elcom Euro-50T Mini" },
        { id: 5, name: "Elcom Euro-50TE Mini" },
        { id: 6, name: "Elcom Euro-50TE Cash (iba úhrada faktúry)" },
        { id: 7, name: "Elcom Euro-50TE Medi" },
        { id: 8, name: "Elcom Euro-50TE Smart (iba úhrada faktúry)" },
        { id: 9, name: "Elcom Euro-150TE Flexy" },
        { id: 10, name: "Elcom Euro-150TE Flexy Plus" },
        { id: 11, name: "Elcom Euro-80B" },
        { id: 12, name: "Elcom Euro-50iTE Mini" },
        { id: 13, name: "Elcom Euro-50iTE Cash" },
        { id: 14, name: "Elcom Euro-150iTE Flexy" },
        { id: 15, name: "Elcom Euro-150iTE Flexy Plus" },
        { id: 16, name: "Elcom Euro-2100i" },
        { id: 17, name: "Varos - eFT4000B/eFT5000B" },
        { id: 18, name: "Varos - eFT4000/FT5000" },
        { id: 19, name: "Bowa" },
        { id: 20, name: "Upos" },
      ],
      ekasaConnections: [
        { id: 0, name: "COM" },
        { id: 1, name: "USB" },
        { id: 2, name: "TCP" },
      ],
      comPorts: [
        { id: 1, name: "COM1" },
        { id: 2, name: "COM2" },
        { id: 3, name: "COM3" },
        { id: 4, name: "COM4" },
        { id: 5, name: "COM5" },
        { id: 6, name: "COM6" },
        { id: 7, name: "COM7" },
        { id: 8, name: "COM8" },
        { id: 9, name: "COM9" },
      ],
      baudRates: [
        { id: 6, name: "9600" },
        { id: 7, name: "14400" },
        { id: 8, name: "19200" },
        { id: 9, name: "38400" },
        { id: 10, name: "56000" },
        { id: 11, name: "57600" },
        { id: 12, name: "115200" },
        { id: 13, name: "128000" },
        { id: 14, name: "256000" },
      ],
      paritys: [
        { id: 0, name: "None" },
        { id: 1, name: "Odd" },
        { id: 2, name: "Even" },
        { id: 3, name: "Mark" },
        { id: 4, name: "Space" },
      ],
      dataBits: [
        { id: 0, name: "4" },
        { id: 1, name: "5" },
        { id: 2, name: "6" },
        { id: 3, name: "7" },
        { id: 4, name: "8" },
      ],
      stopBits: [
        { id: 0, name: "One" },
        { id: 1, name: "OneAndHalf" },
        { id: 2, name: "Two" },
      ],
      flowControls: [
        { id: 0, name: "None" },
        { id: 1, name: "XonXOff" },
        { id: 2, name: "RtsCts" },
        { id: 3, name: "DtrDsr" },
      ],
      alertData: <{ message?: string; type?: string; timeout?: Number }>{},
      devEnv: dev,
      baseUrl: dev ? "http://192.168.30.129/" : location.href,
    };
  },

  methods: {
    keyClick(keyName: any) {
      //console.log(keyName, "keyClick");
    },
    async fetchSettings() {
      try {
        const response = await fetch(this.baseUrl + "api/settings");
        this.settings = await response.json();
      } catch (error) {
        this.showAlert(String(error), "alert-danger");
      }
    },
    async postData(url = "", data = {}) {
      // Default options are marked with *
      const response = await fetch(url, {
        method: "POST", // *GET, POST, PUT, DELETE, etc.
        //mode: "cors", // no-cors, *cors, same-origin
        cache: "no-cache", // *default, no-cache, reload, force-cache, only-if-cached
        //credentials: "same-origin", // include, *same-origin, omit
        headers: {
          "Content-Type": "application/json",
        },
        //redirect: "follow", // manual, *follow, error
        //referrerPolicy: "no-referrer", // no-referrer, *no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
        body: JSON.stringify(data), // body data type must match "Content-Type" header
      });
      return response.json(); // parses JSON response into native JavaScript objects
    },
    onChangeEkasaTyp(event: any) {
      this.settings.ekasa.typ = Number(event.target.value);
      this.settings.ekasa.typStr = this.ekasaTyps[this.settings.ekasa.typ].name;
    },
    onChangeConnection(event: any) {
      this.settings.ekasa.connectionTyp = Number(event.target.value);
    },
    onChangeDrawer(event: any) {
      this.settings.ekasa.drawer = Number(event.target.value);
    },
    onChangeHeaderBitmap(event: any) {
      this.settings.ekasa.headerBitmap = Number(event.target.value);
    },
    onChangeFooterBitmap(event: any) {
      this.settings.ekasa.footerBitmap = Number(event.target.value);
    },
    onChangeComPort(event: any) {
      this.settings.scanner.comPort = Number(event.target.value);
    },
    onChangeBaudrate(event: any) {
      this.settings.scanner.baudRate = Number(event.target.value);
    },
    onChangeParity(event: any) {
      this.settings.scanner.parity = Number(event.target.value);
    },
    onChangeDatabits(event: any) {
      this.settings.scanner.dataBits = Number(event.target.value);
    },
    onChangeStopbits(event: any) {
      this.settings.scanner.stopBits = Number(event.target.value);
    },
    showAlert(message: string, type = "alert-success", timeout = 250000) {
      this.alertData = { message, type };
      setTimeout(() => {
        this.alertData = {};
      }, timeout);
    },
    async onSave() {
      try {
        const response = await this.postData(this.baseUrl + "api/settings", this.settings);
        this.showAlert("Nastavenie uložené");
        this.showSettings('overview');
      } catch (error) {
        this.showAlert(String(error), "alert-danger");
      }
    },
    onCopy() {
      let textarea = document.getElementById("bearerToken") as any;
      textarea.select();
      document.execCommand("copy");
    },
    showSettings(item: string) {
      if (item === 'overview') {
        this.ekasaSet = false
        this.scannerSet = false
      }
      if (item === 'ekasa') {
        this.ekasaSet = true
        this.scannerSet = false
      }
      if (item === 'scanner') {
        this.ekasaSet = false
        this.scannerSet = true
      }
    }
  },
  async mounted() {
    await this.fetchSettings();
  }
};
</script>

<template>
  <div class="alert"
    :class="{ 'alert-success': alertData.type == 'alert-success', 'alert-danger': alertData.type == 'alert-danger' }"
    role="alert" v-if="alertData.message">
    {{ alertData.message }}
  </div>

  <nav class="navbar navbar-default">
    <div class="container" style="display:block !important">
      <div class="row">
        <div class="col-md-6">
          <a style="float: left; display: inline-block">
            <img alt="MRP účtovníctvo mzdy sklad fakturácia" class="logo" height="80" src="./assets/logo_mrp.png" />
          </a>
          <h1 class="app-name">eKASA Printer</h1>
        </div>
        <div class="col-md-6 button-container">
          <div type="button" class="btn btn-light" style="margin: 10px" @click="showSettings('overview')">Prehľad</div>
          <div class="dropdown">
            <button type="button" class="btn btn-light dropdown-toogle" data-bs-toggle="dropdown"
              style="margin: 10px">Nastavenie</button>
            <ul class="dropdown-menu">
              <li><a class="dropdown-item" @click="showSettings('ekasa')">eKasa</a></li>
              <li><a class="dropdown-item" @click="showSettings('scanner')">Scanner</a></li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </nav>

  <div class="container">
    <div class="row" v-if="ekasaSet == false && scannerSet == false">
      <div class="col-md-6">
        <div class="card" style="margin-bottom: 30px;">
          <div class="card-header">
            <div class="inline">Ekasa</div>
          </div>
          <div class="card-body">
            {{ settings.ekasa.typ === 0 ? 'Nenakonfigurová' : settings.ekasa.typStr }}
          </div>
        </div>
      </div>
      <div class="col-md-6">
        <div class="card" style="margin-bottom: 30px;">
          <div class="card-header">
            <div class="inline">Scanner</div>
          </div>
          <div class="card-body">
            {{ settings.scanner.use ? 'Scanner pripojený na COM' + String(settings.scanner.comPort) :
             'Scanner sa nepoužíva'}}
          </div>
        </div>
      </div>
    </div>
    <div class="row" v-if="ekasaSet == false && scannerSet == false">
      <div class="col-md-12">
        <div class="card" style="margin-bottom: 30px;">
          <div class="card-header">
            <div class="inline">Bearer token</div>
          </div>
          <div class="card-body">
            <div class="col-md-12">
              <textarea id="bearerToken" readonly style="width:100%" v-model="settings.bearerToken"
                placeholder="vložte text"></textarea>
              <!-- <input v-model="settings.bearerToken" /> -->
            </div>
            <div class="row" style="margin-bottom: 10px">
              <div class="col-md-12 text-center">
                <button type="button" class="right btn btn-danger" @click="onCopy()">Skopírovať</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="row" v-if="ekasaSet">
      <div class="col-md-12">
        <div class="card">
          <div class="card-header">
            <div class="inline">Nastavenie online eKasy</div>
          </div>
          <div class="card-body">
            <div class="row" style="margin-bottom: 10px">
              <div class="col-md-6">
                <strong>Vyberte typ pripojenej eKasy</strong>
              </div>
              <div class="col-md-6">
                <select class="form-select" aria-label="Default select example" @change="onChangeEkasaTyp($event)">
                  <option v-for="ekasaTyp in ekasaTyps" v-bind:value="ekasaTyp.id"
                    :selected="settings.ekasa?.typ == ekasaTyp.id">{{ ekasaTyp.name }}</option>
                </select>
              </div>
            </div>
            <div class="row" v-if="settings.ekasa?.typ > 0">
              <div class="row"
                v-if="[2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20].includes(settings.ekasa?.typ)"
                style="margin-bottom: 10px">
                <div class="col-md-6">
                  <strong>Typ pripojenia</strong>
                </div>
                <div class="col-md-2">
                  <input type="radio" id="com" value="0" @change="onChangeConnection($event)"
                    v-model="settings.ekasa.connectionTyp" />
                  <label for="com">COM</label>
                </div>
                <div class="col-md-2">
                  <input type="radio" id="usb" value="1" @change="onChangeConnection($event)"
                    v-model="settings.ekasa.connectionTyp" />
                  <label for="usb">USB</label>
                </div>
                <div class="col-md-2">
                  <input type="radio" id="tcp" value="2" @change="onChangeConnection($event)"
                    v-model="settings.ekasa.connectionTyp" />
                  <label for="tcp">TCP</label>
                </div>
              </div>

              <div class="row"
                v-if="[0, 1].includes(settings.ekasa.connectionTyp) && [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20].includes(settings.ekasa?.typ)"
                style="margin-bottom: 10px">
                <div class="col-md-6">
                  <strong>Nastavenie pripojenia cez COM/USB</strong>
                </div>
                <div class="col-md-6">
                  <input v-model="settings.ekasa.comPort" />
                </div>
              </div>

              <div class="row" v-if="[2].includes(settings.ekasa.connectionTyp) || settings.ekasa?.typ == 1"
                style="margin-bottom: 10px">
                <div class="col-md-6">
                  <strong>Nastavenie pripojenia cez TCP</strong>
                </div>
                <div class="col-md-6">
                  <input v-model="settings.ekasa.hostAddress" placeholder="127.0.0.1" />
                </div>
              </div>

              <!-- only Mrp(1) FiskalPro(2) & Varos(18) -->
              <div class="row" v-if="[1, 2, 18].includes(settings.ekasa?.typ)">
                <div class="row" style="margin-bottom: 10px">
                  <div class="col-md-6">
                    <strong>Variabilná hlavička dokladu</strong>
                  </div>
                  <div class="col-md-6">
                    <textarea v-model="settings.ekasa.header" placeholder="vložte text"></textarea>
                  </div>
                </div>
                <div class="row" style="margin-bottom: 10px">
                  <div class="col-md-6">
                    <strong>Variabilná pätička dokladu</strong>
                  </div>
                  <div class="col-md-6">
                    <textarea v-model="settings.ekasa.footer" placeholder="vložte text"></textarea>
                  </div>
                </div>
              </div>
              <div class="row" style="margin-bottom: 10px">
                <div class="col-md-6">
                  <strong>Zapnúť log komunikácie</strong>
                </div>
                <div class="col-md-6">
                  <input type="checkbox" id="withLog" v-model="settings.ekasa.withLog" />
                </div>
              </div>
              <div class="row" style="margin-bottom: 10px">
                <div class="col-md-6">
                  <strong>Pri úhrade faktúry tlačiť kópiu dokladu</strong>
                </div>
                <div class="col-md-6">
                  <input type="checkbox" id="copyInvoice" v-model="settings.ekasa.copyInvoice" />
                </div>
              </div>

              <!-- only Varos(17) & Bowa(19) -->
              <div class="row" v-if="[17, 19].includes(settings.ekasa?.typ)">
                <div class="row" style="margin-bottom: 10px">
                  <div class="col-md-6">
                    <strong>Platca DPH</strong>
                  </div>
                  <div class="col-md-6">
                    <input type="checkbox" id="vatPayer" v-model="settings.ekasa.vatPayer" />
                  </div>
                </div>
                <div class="row" style="margin-bottom: 10px">
                  <div class="col-md-6">
                    <strong>Tlač v položke celý názov</strong>
                  </div>
                  <div class="col-md-6">
                    <input type="checkbox" id="printFullName" v-model="settings.ekasa.printFullName" />
                  </div>
                </div>
                <div class="row" style="margin-bottom: 10px">
                  <div class="col-md-6">
                    <strong>Otváranie pokladničnej zásuvky</strong>
                  </div>
                  <div class="col-md-6">
                    <select class="form-select" aria-label="Default select example" @change="onChangeDrawer($event)">
                      <option v-bind:value="settings.ekasa.drawer" :selected="settings.ekasa.drawer == 0">0</option>
                      <option v-bind:value="settings.ekasa.drawer" :selected="settings.ekasa.drawer == 1">1</option>
                    </select>
                  </div>
                </div>
                <div class="row" style="margin-bottom: 10px">
                  <div class="col-md-12">
                    <strong>Číslo bitmapy grafického loga tlačeného</strong>
                  </div>
                </div>
                <div class="row" style="margin-bottom: 10px">
                  <div class="col-md-6">
                    <strong>na začiatku dokladu</strong>
                  </div>
                  <div class="col-md-6">
                    <select class="form-select" aria-label="Default select example"
                      @change="onChangeHeaderBitmap($event)">
                      <option v-for="i in 7" v-bind:value="i - 1" :selected="settings.ekasa.headerBitmap == i - 1">{{ i -
                        1 }}
                      </option>
                    </select>
                  </div>
                </div>
                <div class="row" style="margin-bottom: 10px">
                  <div class="col-md-6 text-center">
                    <strong>na konci dokladu</strong>
                  </div>
                  <div class="col-md-6">
                    <select class="form-select" aria-label="Default select example"
                      @change="onChangeFooterBitmap($event)">
                      <option v-for="i in 7" v-bind:value="i - 1" :selected="settings.ekasa.footerBitmap == i - 1">{{ i -
                        1 }}
                      </option>
                    </select>
                  </div>
                </div>
              </div>
            </div>
            <div class="row" style="margin-bottom: 10px">
              <div class="col-md-12 text-center">
                <button type="button" class="right btn btn-danger" @click="onSave()">Uložiť</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="row" v-if="scannerSet">
      <div class="col-md-12">
        <div class="card" style="margin-bottom: 30px;">
          <div class="card-header">
            <div class="inline">Nastavenie scanneru</div>
          </div>
          <div class="card-body">
            <div class="row" style="margin-bottom: 10px">
              <div class="col-md-6">
                <strong>Používať scanner</strong>
              </div>
              <div class="col-md-6">
                <input type="checkbox" id="withLog" v-model="settings.scanner.use" />
              </div>
            </div>
            <div class="row" v-if="settings.scanner.use">
              <div class="row" style="margin-bottom: 10px">
                <div class="col-md-6">
                  <strong>COM port</strong>
                </div>
                <div class="col-md-6">
                  <select class="form-select" aria-label="Default select example" @change="onChangeComPort($event)">
                    <option v-for="comPort in comPorts" v-bind:value="comPort.id"
                      :selected="settings.scanner.comPort == comPort.id">{{ comPort.name }}</option>
                  </select>
                </div>
              </div>
              <div class="row" style="margin-bottom: 10px">
                <div class="col-md-6">
                  <strong>Baudrate</strong>
                </div>
                <div class="col-md-6">
                  <select class="form-select" aria-label="Default select example" @change="onChangeBaudrate($event)">
                    <option v-for="baudRate in baudRates" v-bind:value="baudRate.id"
                      :selected="settings.scanner.baudRate == baudRate.id">{{ baudRate.name }}</option>
                  </select>
                </div>
              </div>
              <div class="row" style="margin-bottom: 10px">
                <div class="col-md-6">
                  <strong>Parity</strong>
                </div>
                <div class="col-md-6">
                  <select class="form-select" aria-label="Default select example" @change="onChangeParity($event)">
                    <option v-for="parity in paritys" v-bind:value="parity.id"
                      :selected="settings.scanner.parity == parity.id">{{ parity.name }}</option>
                  </select>
                </div>
              </div>
              <div class="row" style="margin-bottom: 10px">
                <div class="col-md-6">
                  <strong>Databits</strong>
                </div>
                <div class="col-md-6">
                  <select class="form-select" aria-label="Default select example" @change="onChangeDatabits($event)">
                    <option v-for="dataBit in dataBits" v-bind:value="dataBit.id"
                      :selected="settings.scanner.dataBits == dataBit.id">{{ dataBit.name }}</option>
                  </select>
                </div>
              </div>
              <div class="row" style="margin-bottom: 10px">
                <div class="col-md-6">
                  <strong>Stopbits</strong>
                </div>
                <div class="col-md-6">
                  <select class="form-select" aria-label="Default select example" @change="onChangeStopbits($event)">
                    <option v-for="stopBit in stopBits" v-bind:value="stopBit.id"
                      :selected="settings.scanner.stopBits == stopBit.id">{{ stopBit.name }}</option>
                  </select>
                </div>
              </div>
              <div class="row" style="margin-bottom: 10px">
                <div class="col-md-6">
                  <strong>Flowcontrol</strong>
                </div>
                <div class="col-md-6">
                  <select class="form-select" aria-label="Default select example" @change="onChangeEkasaTyp($event)">
                    <option v-for="flowControl in flowControls" v-bind:value="flowControl.id"
                      :selected="settings.scanner.flowControl == flowControl.id">{{ flowControl.name }}</option>
                  </select>
                </div>
              </div>
            </div>
            <div class="row" style="margin-bottom: 10px">
              <div class="col-md-12 text-center">
                <button type="button" class="right btn btn-danger" @click="onSave()">Uložiť</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

<!-- 
    <div class="row" v-if="devEnv">
      {{ settings }}
    </div> -->
  </div>
</template>

<style scoped>
.button-container {
  display: flex;
  align-items: center !important;
}
</style>
