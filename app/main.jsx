var React = require('react/addons');


console.log("hello from JSX");

//this will happen where all the rendering happens

var GroceryItemList = require('./components/GroceryItemList.jsx');

var groceryItemStore = require('./stores/GroceryItemStore.jsx');
var initial = groceryItemStore.getItems();

function render() {
    React.render()(<GroceryItemList items = {initial} />, app)
}
groceryItemStore.onChange(function (items) {
    initial = items;
    render();
})

React.render(<GroceryItemList Items={initial}/>, app)