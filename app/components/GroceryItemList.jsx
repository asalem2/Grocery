var React = require('react/addons');
var GroceryItem = require('./GroceryItem');
var GroceryListAddItem = require('./GroceryListAddItem');

//module will allow any file to quickly access our grocery list
module.exports = React.createClass({
    render: function () {
        return (
            <div>
                <h1>Grocery List</h1>
                <div>
                    {this.props.items.map(function (item, index) {
                        return (
                            <GroceryItem item = {item} key={"item" + index}/>
                        )
                    })
                    }
                </div>
                <GroceryListAddItem />
            </div>
        )
    }
})