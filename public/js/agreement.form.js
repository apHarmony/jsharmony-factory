/*
Copyright 2017 apHarmony

This file is part of jsHarmony.

jsHarmony is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

jsHarmony is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this package.  If not, see <http://www.gnu.org/licenses/>.
*/

$(document).ready(function () {
  $('#A_Date').val(moment().format('MM/DD/YYYY'));

  //Sample Data
  /*$('#A_Name').val('Slim Stanowski');
  $('#A_DOB').val('9/9/1990');
  $('#A_Accept').prop('checked', true);*/
  
  //Set up Step 1
  _.each(XFormStep1.prototype.Fields, function (field, fieldid) {
    field.name = fieldid;
    if (!('validators' in field)) return;
    XFormStep1.prototype.xvalidate.AddControlValidator('#' + field.name, '_obj.' + field.name, field.caption, 'I', field.validators);
  });
});

/**************************
 * STEP 1
 * *************************/
function step1_init() { }

function step1_submit() {
  var xf = new XFormStep1();
  xf.GetValues();
  xf.xvalidate = XFormStep1.prototype.xvalidate;
  var xp = new XPost();
  xp.Data = xf;
  var valid = xp.Validate('I');
  delete xf.xvalidate;
  if (!valid) return;
  
  SignAgreement(xf);
}

function _v_IsChecked() {
  var _val = $('#A_Accept').prop('checked');
  if (!_val) return "E-signature must be checked to continue.";
  return "";
}

function XFormStep1() { }
XFormStep1.prototype.Fields = {
  "A_Accept": { "caption": "E-signature", "access": "I", "validators": [XValidate._v_Required(), _v_IsChecked] },
  "A_Date": { "caption": "Today's Date", "access": "I", "validators": [XValidate._v_Required(), XValidate._v_MaxLength(10), XValidate._v_IsDate()] },
  "A_Name": { "caption": "Signed Name", "access": "I", "validators": [XValidate._v_Required(), XValidate._v_MaxLength(72)] },
  "A_DOB": { "caption": "Date of Birth", "access": "I", "validators": [XValidate._v_Required(), XValidate._v_MaxLength(10), XValidate._v_IsDate(), XValidate._v_IsValidDOB(), XValidate._v_MinDOB(18)] }
}
XFormStep1.prototype.GetValues = function () {
  var _this = this;
  _.each(this.Fields, function (field) {
    _this[field.name] = _this.GetValue(field);
  });
};
XFormStep1.prototype.GetValue = function (field) {
  var val = $('#' + field.name).val();
  if ('format' in field) {
    var format = field.format;
    if (_.isString(format)) val = XFormat[format + '_decode'](val);
    else {
      var fargs = [];
      for (var i = 1; i < format.length; i++) fargs.push(format[i]);
      fargs.push(val);
      val = XFormat[format[0] + '_decode'].apply(this, fargs);
    }
  }
  return val;
}
XFormStep1.prototype.xvalidate = new XValidate();


//AppSrv Logic
function SignAgreement(data) {
  var d = {
    'A_Name': data.A_Name,
    'A_DOB': data.A_DOB
  };
  XPost.prototype.XExecutePost('../agreement/_sign', d, function (rslt) {
    if ('_success' in rslt) {
      window.location.href = _BASEURL + 'agreement/welcome/';
    }
  });
}