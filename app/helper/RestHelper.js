var $ = require('jquiry');

module.exports = {
    get:function (url) {
        return new Promise(function (success, error) {
            $.ajax({
                url: url,
                //string json is used here because usage of double quotes (jquery rule)
                dataType:"json",
                success: success,
                error: error
            })
        })
    },
    //request payload of data that should be added to our collection of data
    post:function (url, data) {
        return new Promise(function (success, error) {
            $.ajax({
                url: url,
                //string json is used here because usage of double quotes (jquery rule)
                type: "POST",
                data: data,
                success: success,
                error: error
            })
        })
    }
}