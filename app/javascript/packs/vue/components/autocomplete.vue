/*
Parameters: 

          mim: Minimum input length needed before make a search query
         time: Minimum time needed after a key pressed to make a search query          
          url: Ajax url request
  placeholder: Input placeholder
        label: name of the propierty displayed on the list
   event-send: event name used to pass item selected
    autofocus: set autofocus
      display: Sets the label of the item selected to be display on the input field
      getInput: Get the input text
   clearAfter: Clear the input field after an item is selected

   :add-param: Send custom parameters
  
  Example:
    <autocomplete 
      url="/contents/filter.json"
      param="hours_ago">
    </autocomplete>
*/
<template>
  <div class="vue-autocomplete">
    <input ref="autofocus" class="vue-autocomplete-input normal-input" type="text" v-bind:placeholder="placeholder" v-on:input="checkTime(), sendType()" v-model="type" :autofocus="autofocus" :disabled="disabled" v-bind:class="{'ui-autocomplete-loading' : spinner, 'vue-autocomplete-input-search' : !spinner }"/>
    <ul class="vue-autocomplete-list" v-show="showList" v-if="type && json.length">
      <li v-for="(item, index) in limitList(json)" class="vue-autocomplete-item" :class="activeClass(index)" @mouseover="itemActive(index)" @click.prevent="itemClicked(item), sendItem(item)">
        <span v-html="item[label]"></span>
      </li>
    </ul>
    <ul v-if="type && searchEnd && !json.length">
      <li>--None--</li>
    </ul>
  </div>
</template>

<script>
export default { 
    data: function () {
      return {
        spinner: false,
        showList: false,
        searchEnd: false,
        getRequest: 0,
        type: this.sendLabel,
        json: [],
        current: -1
      };
    },

    mounted: function() {
      if(this.autofocus) {
        this.$refs.autofocus.focus();
      }
    },

    watch: {
      type: function() {
        if(this.type.length < Number(this.min)) {
          this.json = [];
        }
      },
      sendLabel: function(val) {
        if(val) {
          this.type = val
        }
      }
    },

    props: {

      autofocus: {
        type: Boolean,
        default: false
      },

      disabled: {
        type: Boolean,
        default: false
      },

      url: {
        type: String
      },

      clearAfter: {
        type: Boolean,
        default: false
      },

      sendLabel: {
        type: String,
        default: ''
      },

      autofocus: {
        type: Boolean,
        default: false
      },

      label: String,

      display: {
        type: String,
        default: '',
      },

      time: {
        type: String,
        default: "500"
      },

      arrayList: {
        type: Array,
        default: undefined
      },

      min: {
        type: String,
        default: 1
      },

      addParams: {
        type: Object
      },

      limit: {
        type: Number,
        default: 0
      },   

      placeholder: {
        type: String,
        default: ''
      },             

      param: {
        type: String,
        default: "value"
      },

      eventSend: {
        type: String,
        default: "itemSelect"
      },            
    },
  
      methods: {
        sendItem: function(item) {
          this.$emit('input', item);
          this.$parent.$emit(this.eventSend, item);
          this.$emit('getItem', item);
        },

        limitList: function(list) {
          if(this.limit == 0) 
            return list

          return list.slice(0, this.limit);
        },

        clearResults: function() {
          this.json = [];
        },

        itemClicked: function(item) {
          if(this.display.length)
            this.type = (this.clearAfter ? '' : item[this.display]);
          else {
            this.type = (this.clearAfter ? '' : item[this.label]);
          }

          if(this.autofocus) {
            this.$refs.autofocus.focus();
          }
          this.showList = false;
        },

        itemActive: function(index) {
          this.current = index;
        },             

        ajaxUrl: function() {
          var tempUrl = this.url + '?' + this.param + '=' + this.type; 
          var params = '';
          if(this.addParams) {
            Object.keys(this.addParams).forEach((key) => {
              params += `&${key}=${this.addParams[key]}`
            })
          }   
          return tempUrl + params;           
        },

        sendType: function() {
          this.$emit('getInput', this.type)
        },

        checkTime: function() {
          var that = this;
          this.searchEnd = false;
          if(this.getRequest) {
            clearTimeout(this.getRequest);
          }   
          this.getRequest = setTimeout( function() {    
            that.update();  
          }, that.time);           
        }, 

        update: function() {
          if(this.type.length < Number(this.min)) return;
          this.spinner = true;
          this.clearResults();   
          if(this.arrayList) {
            var finded = [];
            var that = this;
            
            this.arrayList.forEach(function(item) {
              if(item[that.label].includes(that.type)) {
                finded.push(item);
              }
            });
            
            this.spinner = false;
            this.json = finded;
            this.searchEnd = true;
            this.showList = (this.json.length > 0)
          }
          else {
            this.$http.get(this.ajaxUrl(), {
              before(request) {
                if (this.previousRequest) {
                  this.previousRequest.abort();
                }
                this.previousRequest = request;
              }            
            }).then(response => {
              this.json = response.body;
              this.showList = (this.json.length > 0)
              this.spinner = false;
              this.searchEnd = true;
            }, response => {
              // error callback
              this.spinner = false;
            });
          }
        },
        activeClass: function activeClass(index) {
          return {
            active: this.current === index
          };
        },   
        activeSpinner: function() {
          return 'ui-autocomplete-loading'
        },                
      }
    };
</script>