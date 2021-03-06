<template>
	<div class="documentation_annotator">
		<div class="separate-bottom">
			<div class="switch-radio">
				<template v-for="item, index in optionList">
				<input 
					v-model="display"
					:value="index"
					:id="`alternate_values-picker-${index}`" 
					name="alternate_values-picker-options"
					type="radio"
					class="normal-input button-active" 
				/>
				<label :for="`alternate_values-picker-${index}`" class="capitalize">{{ item }}</label>
				</template>
			</div>
		</div>

		<div class="field" v-if="display == 0">
		    <dropzone class="dropzone-card" v-on:vdropzone-sending="sending" v-on:vdropzone-success="success" ref="figure" id="figure" url="/documentation" :useCustomDropzoneOptions="true" :dropzoneOptions="dropzone"></dropzone>
			</div>

		<div v-if="display == 1">
			<autocomplete
				class="field"
				url="/documents/autocomplete"
				label="label"
				min="2"
				placeholder="Select a document"
				@getItem="documentation.document_id = $event.id"
				param="term">
			</autocomplete>
	    	<button @click="createNew()" :disabled="!validateFields" class="button button-submit normal-input separate-bottom" type="button">Create</button>
		</div>

	    <display-list label="object_tag" :list="list" @delete="removeItem" class="list"></display-list>
	</div>
</template>
<script>

	import CRUD from '../request/crud.js';
	import annotatorExtend from '../components/annotatorExtend.js';
	import autocomplete from '../../autocomplete.vue';
	import dropzone from '../../dropzone.vue';
	import displayList from './displayList.vue';

	export default {
		mixins: [CRUD, annotatorExtend],
		components: {
			displayList,
			autocomplete,
			dropzone
		},
		computed: {
			validateFields() {
				return this.documentation.document_id
			}
		},
		data: function() {
			return {
				display: 0,
				optionList: ['drop', 'pick', 'pinboard'],
				list: [],
				documentation: this.newDocumentation(),
				dropzone: {
					paramName: "documentation[document_attributes][document_file]",
					url: "/documentation",
					headers: {
						'X-CSRF-Token' : document.querySelector('meta[name="csrf-token"]').getAttribute('content')
					},
					dictDefaultMessage: "Drop documents here",
					acceptedFiles: 'application/pdf, text/plain'
				},
			}
		},
		methods: {
			newDocumentation() {
				return {
					document_id: null,
					annotated_global_entity: decodeURIComponent(this.globalId)
				}
			},
			createNew() {
				this.create('/documentation', { documentation: this.documentation }).then(response => {
					this.list.push(response.body);
					this.documentation = this.newDocumentation();
				});
			},
	        'success': function(file, response) {
	        	this.list.push(response);
	        	this.$refs.figure.removeFile(file);
	        },
	        'sending': function(file, xhr, formData) {
	          	formData.append("documentation[annotated_global_entity]", decodeURIComponent(this.globalId));
	        },
	        updateFigure() {
	        	this.update(`/depictions/${this.depiction.id}`, this.depiction).then(response => {
	        		this.$set(this.list, this.list.findIndex(element => this.depiction.id == element.id), response.body);
	        		this.depiction = undefined;
	        	});
	        }
		}
	}
</script>
<style type="text/css" lang="scss">
.radial-annotator {
	.documentation_annotator { 
		textarea {
			padding-top: 14px;
			padding-bottom: 14px;
			width: 100%;
			height: 100px;
		}
		.vue-autocomplete-input {
			width: 100%;
		}
	}
}
</style>