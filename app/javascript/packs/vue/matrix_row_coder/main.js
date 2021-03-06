var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.matrix_row_coder = TW.views.tasks.matrix_row_coder || {};

import Vue from 'vue';
import props from './props';
import tempApp from './tempApp.vue';

Object.assign(TW.views.tasks.matrix_row_coder, {
	init: function() {
		new Vue({
		    el: '#matrix_row_coder_bar',
		    render: function (createElement) {
		        return createElement(tempApp);
		    }
		});
	},
});

$(document).on('turbolinks:load', function() {
  if ($("#matrix_row_coder").length) {
    TW.views.tasks.matrix_row_coder.init();
  }
});