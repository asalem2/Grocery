var React = require('react/addons');
var action = require('./../actions/GroceryItemActionCreator.')

module.exports = React.createClass({
    togglePurchased:function (e) {
        e.preventDefault();

        if(this.props.items.purchased){
            action.unbuy(this.props.item);
        } else {
            action.buy(this.props.item);
        }
    },
    delete:function (e) {
        e.preventDefault();
        action.delete(this.props.item);
    },
    render: function () {
        return (
            <div className="grocery-item row">
                <div className="six columns">
                    <h4 className={this.props.item.purchased ? "strikethrough" : ""}> {this.props.item.name} </h4>
                </div>
                <form className="three columns" onSubmit={this.togglePurchased}>
                    <button className={this.props.item.purchased ? "" : "button-primary"}> {this.props.item.purchased ? "unbuy" : "buy"} </button>
                </form>
                <form className="three columns" onSubmit={this.delete}>
                </form>
            </div>
        )
    }
})