<template>
  <div :class="{ disabled : contents.length == 0 }">
    <div @click="showModal = true && contents.length > 0" class="item flex-wrap-column middle menu-button">
      <span data-icon="clone" class="big-icon"></span><span class="tiny_space">Clone</span>
    </div>
    <modal v-if="showModal" id="clone-modal" @close="showModal = false"> 
    <h3 slot="header">Clone</h3> 
      <div slot="body"> 
        <ul class="no_bullets"> 
          <li v-for="item in contents" @click="cloneCitation(item.text)">
            <span data-icon="show"><div class="clone-content-text">{{ item.text }}</div></span><span v-html="item.object_tag"></span>
          </li> 
        </ul> 
      </div> 
    </modal> 
  </div>
</template>

<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const removeDuplicate = require('../helpers/removeDuplicate');
  const modal = require('../../../components/modal.vue').default;
  
  export default {

      data: function() {
        return {
          contents: [],
          showModal: false
        }
      },
      name: 'clone-conent',
      computed: {
        disabled() {
          return (this.$store.getters[GetterNames.GetContentSelected] == undefined)
        },  
        topic() {
          return this.$store.getters[GetterNames.GetTopicSelected]
        },
        content() {
          return this.$store.getters[GetterNames.GetContentSelected]
        },        
        otu() {
          return this.$store.getters[GetterNames.GetOtuSelected]
        }        
      },
      watch: {
        'content': function(val, oldVal) {
          if(val != undefined) {
            if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
              this.loadContent();
            }
          }
          else {
            this.contents = [];
          }
        }
      },      
      methods: {
        loadContent: function() {
          if (this.disabled) return
          var that = this,
           ajaxUrl = `/contents/filter.json?topic_id=${this.topic.id}`;
          this.$http.get(ajaxUrl).then( response => {
            that.contents = removeDuplicate(response.body,this.content.id);
          });          
        },
        cloneCitation: function(text) {
          this.$parent.$emit('addCloneCitation', text);
          this.showModal = false;
        }
      },
      components: {
        modal
      }

    }
</script>