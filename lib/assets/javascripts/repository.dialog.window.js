//= require repository.dialog.upload
/**
 * Objeto com propriedades de realizar buscas de repositorios(JSON),
 * gerar resultado de busca, apendar resultado onde for desejado.
 */
WEBY.Repository = function (object) {
   for(property in object) {
      this[property] = object[property];
   }

   var getMIMEPath = function (mime) {
      return "/assets/mime_list/" + mime + ".png";
   };

   var getEmptyMIMEPath = function () {
      return "/assets/mime_list/VAZIO.png";
   };

   var getSubTypeOfMIME = function (mime) {
      return mime.split('/').pop();
   };

   try {
      if(this.archive_content_type == "" || this.archive_content_type == null){
          this.image_path = getEmptyMIMEPath();
      } else if(this.archive_content_type.match(/image|svg/ig)) {
         this.image_path = this.mini_path;//this.archive_url;
      } else {
         /////FIX this FIX
         if(this.archive_file_name.match(/\.pdf$/) && this.archive_content_type.match(/(\-download|save)$/)) this.archive_content_type = "application/pdf";
         if(this.archive_file_name.match(/\.doc$/) && this.archive_content_type.match(/(\-download|save)$/)) this.archive_content_type = "application/msword";
         
         this.image_path = getMIMEPath(getSubTypeOfMIME(this.archive_content_type));
      }
   } catch(error) {
      console.error('WEBY.Repository: archive_content_type não informado\n' + error.message);
   }
};

WEBY.Repository.ItemTemplate = function (repository, fieldName, multiple, checked) {
   var input_type = multiple ? 'checkbox' : 'radio';
   repository.input_type = input_type;
   repository.fieldName = fieldName;
   repository.checked = checked ? 'checked' : '';
   var templateString = "<li " +
      (repository.checked ? " class='backgrounded'>" : ">") +
      "<input name='dialog_{fieldName}' type='{input_type}' id='dialog_repository_{id}'"+
      " value='{id}' " +
      (repository.checked ? " checked='{checked}' />"  : " /> ") +
      "<label for='dialog_repository_{id}'>" +
      "<figure>" +
      "<img alt='{archive_file_name}' title='{archive_file_name}' src='{image_path}'/>" +
      "<figcaption>{description}</figcaption>" +
      "</figure>" +
      "</label>" +
      "</li>";

   return templateString.supplant(repository);
}

WEBY.Repository.UniqTemplate = function (repository, fieldName, checked) {
   return WEBY.Repository.
      ItemTemplate(repository, fieldName, false, checked).
      replace(/<li[^>]*>|<\/li>/gi,'');
}


WEBY.RepositoryDialog = function(){
  var settings,
    getting = false,
    selected,
    removed,
    current_page,
    num_pages,
    dialog = this,
    dialogElement = $('#dialog-repository-search'),
    form = $("#repository-search-form"),
    results = $('#repositories-search-results');

   var hideUnusedOption = function (option) {
      var regexpOfTypes = new RegExp('(' + settings.file_types.join('|') + ')', 'gi');
      if ($(option).val() && !$(option).val().match(regexpOfTypes)) {
         $(option).attr("disabled", "disabled").
            removeAttr("selected").hide();
      } else {
         $(option).removeAttr('disabled').show();
      }
   }

   var hideUnusedOptgroups = function () {
      $("#mime_type_").find("optgroup").each(function(index, optgroup){
         var hide = true;
         $(optgroup).find('option').each(function(index, option){
            hideUnusedOption(option);
            if(!option.style.cssText.match(/display:\s*none/gi)){
               hide = false;
            }
         });
         if (hide) {
            $(optgroup).attr('disabled', 'disabled').hide();
         } else {
            $(optgroup).removeAttr('disabled').show();
         }
      });
   }

   var setAllOptionValue = function () {
      $(".search-filter").select2('val', null);
      $("input[name='empty_filter[]']").remove();
      $(settings.file_types).each(function(){
         $('.repo-search').append('<input type="hidden" name="empty_filter[]" value="'+this+'"/>')
      });
   }

  this.clear = function(){
    results.html(null);
    getting = false;
    selected = null;
    removed = null;
    form.find("#search").val("");
    current_page = 0;
    num_pages = 0;
    $("#search-page").val('1')
  }

  var setFileTypeFilter = function(){
    settings.file_types = $.grep(settings.file_types, function(element) {
      if( element && element !== "false" ) {
        return element;
      }
    });

    settings.file_types.toString = function () {
      if (this.length > 1) {
        return '[' + this.join(',') + ']';
      }
      return this[0];
    }
    
  }

  this.open = function(options){
    settings = options;
    dialog.clear();
    //
    setFileTypeFilter();
    hideUnusedOptgroups();
    setAllOptionValue();
    dialogElement.modal('show');
  }
  
  this.close = function(){
    dialogElement.modal('hide');
  }
  
  $(document).on('click', '#repository-include-link', function(){
    if(settings.onsubmit){
      settings.onsubmit.call(dialogElement, selected, removed);
      dialog.close();
    }
  });

  var isSelected = function(repository){
    var result = false;
    if(settings.selected){
      if(typeof settings.selected == 'string' || settings.selected instanceof String){
        if(repository.image_path.match(settings.selected))
          includeSelected(repository);
      }else{
        $(settings.selected).each(function(){
          if($(this).val() == repository.id){
            includeSelected(repository);
          }
        });
      }
    }
    if(selected){
      $(selected).each(function(){
        if(this.id == repository.id){
          result = true;
          return false; //break from the each function
        }
      });
    }
    return result;
  }

  var performSearch = function(){
    getting = true;
    $.get(form.attr('action'), form.serialize(), function(data){
      num_pages = data.num_pages;
      current_page = data.current_page;
      if(data.repositories.length == 0 && data.num_pages == 0){
        results.append('<div class="alert">'+form.data('noresult')+'</div>');
      }else{
        $(data.repositories).each(function (index, node) {
          var repository = new WEBY.Repository(node.repository);
          var checked = isSelected(repository);
          results.append(WEBY.Repository.ItemTemplate(repository, settings.field_name || 'repository', settings.multiple, checked));
          $('#dialog_repository_'+repository.id).data('object', repository);
        });
      }
    }).fail(function(){
      //
    }).done(function(){
      getting = false;
    });
  }

  form.submit(function(){
    results.html(null);
    performSearch();
    return false;
  });

  results.scroll(function(){
      var position = this.scrollTop / (this.scrollHeight - this.clientHeight);

      if(position >= 0.75 && current_page < num_pages && !getting){
        form.find("#search-page").val(function () {
           return parseInt($(this).val()) + 1;
        });
        performSearch();
      }
  });

  var includeSelected = function(object){
    if(!settings.multiple){
      selected = [object];
    }else{
      if(!selected) selected = []
      selected.push(object);
    }
  }

  var removeSelected = function(object){
    selected = $.grep(selected, function(sel) {
      return sel.id != object.id;
    });
    if(!removed) removed = []
    removed.push(object);
    if(settings.selected){
      if(typeof settings.selected == 'string' || settings.selected instanceof String){
        if(object.image_path.match(settings.selected))
          settings.selected = null;
      }else{
        settings.selected = $.grep(settings.selected, function(sel) {
          return $(sel).val() != object.id;
        });
      }
    }
  }

  results.on('change', 'input', function () {
    var input = $(this);
    if (input.is(':checked')){
      input.parent('li').addClass('backgrounded');
      if(!settings.multiple){
        input.parent('li').siblings().removeClass('backgrounded');
      }
      includeSelected(input.data('object'));
    }else{
      removeSelected(input.data('object'));
      input.parent('li').removeClass('backgrounded');
    }
  });

}

// Singleton'ish'
WEBY.getRepositoryDialog = function(){

  if(!this.repositoryDialogInstance){
    this.repositoryDialogInstance = new WEBY.RepositoryDialog();
  }

  return this.repositoryDialogInstance;
}
