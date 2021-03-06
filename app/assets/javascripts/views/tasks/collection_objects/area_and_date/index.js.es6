var TW = TW || {};
TW.views = TW.views || {};
TW.views.tasks = TW.views.tasks || {};
TW.views.tasks.collection_objects = TW.views.tasks.collection_objects || {};

Object.assign(TW.views.tasks.collection_objects, {
  
  init: function () {
    
    var result_collection,
      that = this;
    
    if ($("#set_area_form").length) {
      var result_map;  // intended for use to display on a map objects which know how to GeoJSON themselves
      //var area_selector = $("#geographic_area_id_for_by_area");
      
      $(".result_map_toggle").click(function (event) {           // switch to the map view
        that.switchMap();
      });
      
      $(".result_list_toggle").click(function (event) {          // switch to the list view
        that.switchList();
      });
      
      $("#toggle-list-map").on("click", function () {
        if ($(this).is(":checked")) {
          that.switchMap();
        }
        else {
          that.switchList();
        }
      });
      
      $("#set_area").click(function (event) {      // register the click handler for the made-from-scratch-button
          $("#area_count").text('????');
          $("#select_area").mx_spinner('show');
          $.get('set_area', $("#set_area_form").serialize(), function (local_data) {
            var popcorn = local_data;
            $("#area_count").text(local_data.html);
            $("#select_area").mx_spinner('hide');
            that.validateResultForFind();
          }, 'json');
          event.preventDefault();
        }
      );
      
      $("#find_area_and_date_commit").click(function (event) {
        that.toggleFilter();
        that.ajaxRequest(event, "find");
      });

      $("#tag_all_button").click(function (event) {
        that.tagForm(event);
      });
      
      $("#download_button").click(function (event) {
        if (that.validateMaxResults(1000)) {
          that.downloadForm(event);
        }
        else {
          TW.workbench.alert.create("To Download- refine result to less than 1000 records");
          return false;
        }
      });
    }
    
    $("#set_otu").click(function (event) {
        $("#otu_count").text('????');
        $("#select_otu").mx_spinner('show');
        $.get('set_otu', $("#set_otu_form").serialize(), function (local_data) {
          $("#otu_count").text(local_data.html);
          $("#select_otu").mx_spinner('hide');
          that.validateResultForFind();
        }, 'json');
        event.preventDefault();
      }
    );
  
    $("#set_id_range").click(function (event) {
        $("#id_range_count").text('????');
        $("#select_id_range").mx_spinner('show');
        $.get('set_id_range', $("#set_id_range_form").serialize(), function (local_data) {
          $("#id_range_count").text(local_data.html);
          $("#select_id_range").mx_spinner('hide');
          that.validateResultForFind();
        }, 'json');
        event.preventDefault();
      }
    );
  
    $("#set_user_date_range").click(function (event) {
        $("#user_date_range_count").text('????');
        $("#select_user_date_range").mx_spinner('show');
        $.get('set_user_date_range', $("#set_user_date_range_form").serialize(), function (local_data) {
          $("#user_date_range_count").text(local_data.html);
          $("#select_user_date_range").mx_spinner('hide');
          that.validateResultForFind();
        }, 'json');
        event.preventDefault();
      }
    );
    
    $("[name='date_type_select']").change(function (event) {
      $.get('get_dates_of_type', $("#set_user_date_range_form").serialize(), function (local_data) {
        that.validateResultForFind();
      }, 'json');
      event.preventDefault();
    });
    
    this.validateResultForFind();

    var formatDate = 'yyyy-MM-dd';
    var startDate = new Date($("#earliest_date").text());
    var endDate = new Date($("#latest_date").text());
    var offset = endDate - startDate;
  
    $("#search_start_date").val(dateFormat((startDate), formatDate));
    $("#search_end_date").val(dateFormat(new Date($("#latest_date").text()), formatDate));
    this.setMinAndMaxDate($("#search_start_date"), dateFormat((startDate), formatDate), dateFormat((endDate), formatDate));
    this.setMinAndMaxDate($("#search_end_date"), dateFormat((startDate), formatDate), dateFormat((endDate), formatDate));

    $("#user_date_range_start").val(dateFormat(new Date($("#first_created").text()), formatDate));
    $("#user_date_range_end").val(dateFormat(new Date($("#last_created").text()), formatDate));
    
    $(".filter-button").on("click", function () {
      that.toggleFilter();
    });
    
    $("#search_start_date, #search_end_date").on("change", function(event) {
      that.updateRangePicker(new Date($("#search_start_date").val()), new Date($("#search_end_date").val()));
      event.preventDefault();
    })

    $("#set_date_form").on("submit", function(event) {
      that.update_and_graph()
      return false;
    })

    $("#set_date_form").on("submit", function(event) {
      that.update_and_graph()
      return false;
    })

    $("#partial_toggle").change(function (event) {
      if ($("#date_count").text() != "????") {
        that.update_and_graph(event)
      }
    });   // click date change
    
    this.updateRangePicker(startDate, endDate);
    
    $("#double_date_range").mouseup(function (event) {
      var range_factor = 1.0;
      var newStartText = $(".label.select-label")[1].textContent;
      var newEndText = $(".label.select-label")[0].textContent;
      var newStartDate = (new Date(newStartText)) / range_factor;
      var newEndDate = range_factor * (new Date(newEndText));
      $("#search_start_date").val(dateFormat(new Date(newStartText), formatDate));
      $("#search_end_date").val(dateFormat(new Date(newEndText), formatDate));
      
      that.update_and_graph(event);
      $(".label.range-label")[0].textContent = $(".label.select-label")[1].textContent;
      $(".label.range-label")[1].textContent = $(".label.select-label")[0].textContent;
      
      that.updateRangePicker(newStartDate, newEndDate);
      
    });
    
    $("#reset_slider").click(function (event) {
        $("#search_start_date").val(dateFormat(new Date($("#earliest_date").text()), formatDate));
        $("#search_end_date").val(dateFormat(new Date($("#latest_date").text()), formatDate));
        that.updateRangePicker(startDate, endDate);
        $("#graph_frame").empty();
        $("#date_count").text("????");
        that.validateResultForFind();
        event.preventDefault();
      }
    );
    
    $(".map_toggle").remove();
    $(".on_selector").remove();
  },

  setMinAndMaxDate: function(element, min, max) {
    $(element).attr('min', min);
    $(element).attr('max', max);
  },

  switchMap: function () {
    $("#paging_span").hide();
    $("#show_list").hide();         // hide the list view
    $("#show_map").show();          // reveal the map
    $(".result_list_toggle").removeAttr('hidden');           // expose the other link
    $(".result_map_toggle").attr('hidden', 'hidden');
    $("[name='[geographic_area_id]']").attr('value', '');
    TW.vendor.lib.google.maps.loadGoogleMapsAPI().then(resolve => {
      this.result_map = TW.views.shared.gis.simple_map.init();
      this.result_map = TW.vendor.lib.google.maps.initializeMap('simple_map_canvas', result_collection);
    });
  },
  
  switchList: function () {
    $("#show_map").hide();          // hide the map
    $("#show_list").show();         // reveal the area selector
    $(".result_map_toggle").removeAttr('hidden');            // expose the other link
    $(".result_list_toggle").attr('hidden', 'hidden');
    $("#drawn_area_shape").attr('value', '');
    $("#paging_span").show();
  },
  
  update_and_graph: function () {
    var that = this;
    
    if (this.validateDates()) {
      this.updateRangePicker(new Date($("#search_start_date").val()), new Date($("#search_end_date").val()));
      $("#select_date_range").mx_spinner('show');
      $.get('set_date', $("#set_date_form").serialize(), function (local_data) {
        $("#date_count").text(local_data.html);
        $("#graph_frame").html(local_data.chart);
        $("#select_date_range").mx_spinner('hide');
        that.validateResultForFind();
      }, 'json');  // I expect a json response
    }
  },
  
  cleanResults: function () {
    $("#show_list").empty();
    $("#result_span").empty();
    $("#paging_span").empty();
  },
  
  toggleFilter: function () {
    $("#result_view").toggle();
  },
  
  validateMaxResults: function (value) {
    if (Number($("#result_span").text()) <= value) {
      return true;
    }
    return false;
  },
  
  validateResultForFind: function () {
    // var i = 0;
    
    if (
      ($("#date_count").text() > 0) ||
      ($("#area_count").text() > 0) ||
      ($("#otu_count").text() > 0) ||
      ($("#id_range_count").text() > 0) ||
      ($("#user_date_range_count").text() > 0)
    ) {
      $("#find_area_and_date_commit").removeAttr("disabled");
    }
    else {
      $("#find_area_and_date_commit").attr("disabled", "disabled");
      $("#download_button").attr("disabled", "disabled");
      $("#tag_all_button").attr("disabled", "disabled");
    }
    this.cleanResults();
  },
  
  updateRangePicker: function (newStartDate, newEndDate) {
    var offset = newEndDate - newStartDate;
    
    $("#double_date_range").rangepicker({
      type: "double",
      startValue: newStartDate,
      endValue: newEndDate,
      translateSelectLabel: function (currentPosition, totalPosition) {
        var timeOffset = offset * ( currentPosition / totalPosition);
        var date = new Date(+newStartDate + parseInt(timeOffset));
        return dateFormat(date, "yyyy/MM/dd");
      }
    });
  },
  
  serializeFields: function () {
    var data = '';
    var params = [];
    
    if ($('#area_count').text() != '????') {
      params.push($("#set_area_form").serialize());
    }
    
    if ($('#date_count').text() != '????') {
      params.push($("#set_date_form").serialize());
    }
    
    if ($('#otu_count').text() != '????') {
      params.push($("#set_otu_form").serialize());
    }
  
    if ($('#id_range_count').text() != '????') {
      params.push($("#set_id_range_form").serialize());
    }
  
    if ($('#user_date_range_count').text() != '????') {
      params.push($("#set_user_date_range_form").serialize());
    }
  
    return data = params.join("&");
  },
  
  downloadForm: function (event) {
    event.preventDefault();
    if (this.validateMaxResults(1000)) {
      $('#download_form').attr('action', "download?" + this.serializeFields()).submit();
    }
    else {
      $("body").append('<div class="alert alert-error"><div class="message">To Download- refine result to less than 1000 records</div><div class="alert-close"></div></div>');
      return false;
    }
  },

  tagForm: function (event) {
    $("#tag_all_form").mx_spinner("show");
    event.preventDefault();
        $.ajax({
          url:'tag_all?' + this.serializeFields(),
          type:'post',
          data: $("#tag_all_form").serialize(),
          dataType: 'json',
          success:function() {
            TW.workbench.alert.create('All tags was successfully created.', 'notice')
            var eventTag = new CustomEvent('tag:update', {
              detail: {
                update: true
              }
            });
            document.dispatchEvent(eventTag);
          },
          complete: function() {
            $("#tag_all_form").mx_spinner("hide");
          }
      });
  },
  
  ajaxRequest: function (event, href) {
    if (this.validateDates() && this.validateDateRange()) {
      $("#find_item").mx_spinner('show');
      $.get(href, this.serializeFields(), function (local_data) {
        // $("#find_item").mx_spinner('hide');  # this has been relocated to .../find.js.erb
      });//, 'json'  // I expect a json response
      $("#download_button").removeAttr("disabled");
      $("#tag_all_button").removeAttr("disabled");
    }
    else {
      $("body").append('<div class="alert alert-error"><div class="message">Incorrect dates</div><div class="alert-close"></div></div>');
    }
    event.preventDefault();
  },
  
  validateDates: function () {
    return (is_valid_date($("#search_start_date").val())) && is_valid_date($("#search_end_date").val());
  },
  
  validateDateRange: function () {
    return (new Date($("#search_start_date").val())) < (new Date($("#search_end_date").val()));
  }
});


$(document).on("turbolinks:load", function () {
  if ($("#co_by_area_and_date").length) {
    var _init_map_table = TW.views.tasks.collection_objects;
    _init_map_table.init();
  }
});
