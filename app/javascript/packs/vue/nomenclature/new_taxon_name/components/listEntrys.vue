<template>
	<div v-show="list.length">
	    	<transition-group class="table-entrys-list" name="list-complete" tag="ul">
	    	<li v-for="item, index in list" :key="item.id" class="list-complete-item flex-separate middle">
			    <span class="list-item">
			    	<template v-for="show in display"> 
			    		<a v-if="isLink(show)" target="_blank" :href="composeLink(item, show)" v-html="item[show.label]"></a>
			    		<span v-else v-html="item[show]"></span>
			    	</template> 
			    </span>
			    <div class="list-controls">
			    	<a :href="`/sources/${item.origin_citation.source_id}/edit`" target="_blank" v-if="getCitation(item)" v-html="getCitation(item)"></a>
					<radial-annotator @close="update()" :globalId="item.global_id"></radial-annotator>		
					<span type="button" title="Remove citation" class="circle-button btn-undo" v-if="getCitation(item)" @click="removeCitation(item)"></span>
		    		<span type="button" class="circle-button btn-delete" @click="$emit('delete', item)">Remove</span>
		    	</div>
	    	</li>
	    	</transition-group>
    </div>
</template>
<script>

const ActionNames = require('../store/actions/actions').ActionNames;
const GetterNames = require('../store/getters/getters').GetterNames;
const autocomplete = require('../../../components/autocomplete.vue').default;
const defaultElement = require('../../../components/getDefaultPin.vue').default;
const citationPages = require('./citationPages.vue').default;
const radialAnnotator = require('../../../components/annotator/annotator.vue').default;

export default {
	components: {
		autocomplete,
		defaultElement,
		citationPages,
		radialAnnotator
	},
	props: ['list', 'display'],
	name: 'list-entrys',
	methods: {
		composeLink(item, show) {
			return show.link + item[show.param]
		},
		isLink(show) {
			if(typeof show === 'string' || show instanceof String) {
				return false;
			}
			else {
				return true;
			}
		},
		update() {
			this.$emit('update');
		},
		getCitation: function(item) {
			return (item.hasOwnProperty('origin_citation') ? item.origin_citation.citation_source_body : undefined)
		},
		sendCitation(sourceId,item) {
			let citation = {
				id: item.id,
				origin_citation_attributes: {
					id: (item.hasOwnProperty('origin_citation') ? item.origin_citation.id : null),
					source_id: sourceId
				}
			}
			this.$emit('addCitation', citation);
		},
		removeCitation(item) {
			let citation = {
				id: item.id,
				origin_citation_attributes: {
					id: (item.hasOwnProperty('origin_citation') ? item.origin_citation.id : null),
					_destroy: true
				}
			}
			this.$emit('addCitation', citation);		
		},
	}
}
</script>

<style lang="scss" scoped>
.pages {
	margin-left: 8px;
	width: 70px;
}
.list-controls {
 	display: flex;
 	align-items:center;
 	flex-direction:row;
 	justify-content: flex-end;
	width: 550px;
}
.pages:disabled {
	background-color: #F5F5F5;
}
.list-item {
	a {
		padding-left: 4px;
		padding-right: 4px;
	}
}
.table-entrys-list {
  	padding: 0px;
  	position: relative;

    li {
		margin: 0px;
		padding: 6px;
		border-top: 1px solid #f5f5f5;
    }
}
.list-complete-item {
  transition: all 1s, opacity 0.2s;

}
.list-complete-enter, .list-complete-leave-to
{
  opacity: 0;
  font-size: 0px;
  border:none;
  transform: scale(0.0);
}
.list-complete-leave-active {
	width: 100%;
	position: absolute;
}
</style>