
  /*
  from: https://github.com/edeustace/inplace-image-changer
  */

  /*
  Add chrome support for sendAsBinary
  */

  if (!XMLHttpRequest.prototype.sendAsBinary) {
    XMLHttpRequest.prototype.sendAsBinary = function(dataStr) {
      var byteValue, ords, ui8a;
      byteValue = function(x) {
        return x.charCodeAt(0) & 0xff;
      };
      ords = Array.prototype.map.call(dataStr, byteValue);
      ui8a = new Uint8Array(ords);
      this.send(ui8a.buffer);
      return null;
    };
  }

  window.com || (window.com = {});

  com.ee || (com.ee = {});

  /*
  */

  this.com.ee.InplaceImageChanger = (function() {

    /*
        Options: 
          maxFileSizeInKB - the max size of files
          onLocalFileTooBig - a call back if the file size is too big
          jsonResponseUrlKey - when reading the json response, it'll use this key to create the img#href
    */

    function InplaceImageChanger(element, options) {
      var defaultOptions;
      this.$element = $(element);
      defaultOptions = {
        maxFileSizeInKB: 400
      };
      if (options != null) {
        this.options = $.extend(defaultOptions, options);
      } else {
        this.options = defaultOptions;
      }
      console.log("maxfile size: " + this.options.maxFileSizeInKB);
      this._createImageTag(this.$element.attr('data-original-content'));
      this._createFileInput();
    }

    InplaceImageChanger.prototype.uploadCompleted = function($element, resultText) {
      var customKey, key, resultObject;
      resultObject = $.parseJSON(resultText);
      customKey = this.$element.attr('data-custom-response-key');
      key = customKey != null ? customKey : "url";
      this._createImageTag(resultObject[key]);
      this._createFileInput();
      if (this.options.uploadCompleted != null) {
        return this.options.uploadCompleted($element, resultText);
      }
    };

    InplaceImageChanger.prototype._createImageTag = function(url) {
      var imageTag;
      var _this = this;
      imageTag = "<img style='cursor:pointer' src='" + url + "'/>";
      this.$element.html(imageTag);
      this.$element.find('img').click(function(event) {
        return _this.$element.find('input').trigger('click');
      });
      return null;
    };

    InplaceImageChanger.prototype._createFileInput = function() {
      var fileInput;
      var _this = this;
      fileInput = "<input \n       style=\"visibility: hidden; width: 1px; height: 1px;\" \n       type=\"file\" \n       name=\"" + (this.$element.attr('data-form-name')) + "\">\n</input>";
      this.$element.append(fileInput);
      this.$element.find('input').change(function(event) {
        return _this._handleFileSelect(event);
      });
      return null;
    };

    InplaceImageChanger.prototype._handleFileSelect = function(evt) {
      var f, files, reader;
      var _this = this;
      console.log("_handleFileSelect");
      files = evt.target.files;
      f = evt.target.files[0];
      reader = new FileReader();
      reader.onloadend = function(evt) {
        return _this._onLocalFileLoadEnd(evt, f);
      };
      reader.readAsBinaryString(f);
      return null;
    };

    InplaceImageChanger.prototype._onLocalFileLoadEnd = function(evt, file) {
      var boundary, formBody, now, xhr;
      var _this = this;
      if (file.size > this.options.maxFileSizeInKB * 1024) {
        if (this.options.onLocalFileTooBig != null) {
          this.options.onLocalFileTooBig(file.size, this.options.maxFileSizeInKB);
        }
        return;
      }
      console.log("_onLocalFileLoadEnd");
      now = new Date().getTime();
      boundary = "------multipartformboundary" + now;
      xhr = new XMLHttpRequest();
      xhr.open("POST", this.$element.attr('data-url'), true);
      xhr.setRequestHeader('content-type', "multipart/form-data; boundary=" + boundary);
      xhr.setRequestHeader("Accept", "application/json");
      formBody = this._buildMultipartFormBody(file, evt.target.result, boundary);
      xhr.sendAsBinary(formBody);
      xhr.onload = function() {
        return _this.uploadCompleted(_this.$element, xhr.responseText);
      };
      return null;
    };

    InplaceImageChanger.prototype._buildMultipartFormBody = function(file, fileBinaryData, boundary) {
      var fileParams, formBuilder, params;
      formBuilder = new com.ee.MultipartFormBuilder(boundary);
      params = this.options.data;
      fileParams = [
        {
          file: file,
          data: fileBinaryData,
          paramName: this.$element.attr('data-form-name')
        }
      ];
      return formBuilder.buildMultipartFormBody(params, fileParams, boundary);
    };

    return InplaceImageChanger;

  })();

  /*
  register with jQuery
  */

  jQuery.fn.inplaceImageChanger = function(options) {
    this.each(function(index) {
      if (!jQuery(this).data('com_ee_inplaceImageChanger')) {
        return jQuery(this).data('com_ee_inplaceImageChanger', new com.ee.InplaceImageChanger(this, options));
      }
    });
    return this;
  };

  window.com || (window.com = {});

  com.ee || (com.ee = {});

  this.com.ee.MultipartFormBuilder = (function() {

    function MultipartFormBuilder(boundary) {
      this.boundary = boundary;
      this.dashdash = "--";
      this.crlf = "\r\n";
    }

    /*
        fileParams = [
           
            {file : file (File)
            data : fileBinaryData
            paramName : name of request parameter}
          
            ...
            ]
    */

    MultipartFormBuilder.prototype.buildMultipartFormBody = function(params, fileParams) {
      var output;
      var _this = this;
      output = "";
      if (params != null) {
        $.each(params, function(i, val) {
          if ((typeof val) === 'function') val = val();
          return output += _this.buildFormSegment(i, val);
        });
      }
      if (fileParams != null) {
        $.each(fileParams, function(i, val) {
          output += _this.buildFileFormSegment(val.paramName, val.file, val.data);
          return null;
        });
      }
      output += this.dashdash;
      output += this.boundary;
      output += this.dashdash;
      output += this.crlf;
      return output;
    };

    MultipartFormBuilder.prototype.buildFormSegment = function(key, value) {
      var contentDisposition;
      contentDisposition = this._buildContentDisposition(key);
      return this._buildFormSegment(contentDisposition, value);
    };

    MultipartFormBuilder.prototype._buildContentDisposition = function(name) {
      var template;
      template = "Content-Disposition: form-data; name=\"${name}\" ";
      return template.replace("${name}", name);
    };

    MultipartFormBuilder.prototype._buildFileContentDisposition = function(formName, fileName) {
      var out;
      this.template = "Content-Disposition: form-data; name=\"${formName}\"; filename=\"${fileName}\" ";
      out = this.template.replace("${formName}", formName);
      out = out.replace("${fileName}", fileName);
      return out;
    };

    MultipartFormBuilder.prototype.buildFileFormSegment = function(formName, file, binaryData) {
      var contentDisposition;
      contentDisposition = this._buildFileContentDisposition(formName, file.name);
      contentDisposition += this.crlf;
      contentDisposition += "Content-Type: " + file.type;
      return this._buildFormSegment(contentDisposition, binaryData);
    };

    MultipartFormBuilder.prototype._buildFormSegment = function(contentDisposition, value) {
      var output;
      output = '';
      output += this.dashdash;
      output += this.boundary;
      output += this.crlf;
      output += contentDisposition;
      output += this.crlf;
      output += this.crlf;
      output += value;
      output += this.crlf;
      return output;
    };

    return MultipartFormBuilder;

  })();
