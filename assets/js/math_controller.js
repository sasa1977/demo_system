import $ from "jquery"
import {Socket} from "phoenix"

let initialize = (csrfToken) => {
  let socket = new Socket("/socket");
  socket.connect();

  let channel = socket.channel("math");
  channel.join().
    receive("ok", (initialMessage) => {
      console.log(1)
    })

  channel.on("sum", payload => {
    $("#results").prepend(`<div>∑(1..${payload.number}) = ${payload.sum}</div>`)
  })

  $("#sumForm").submit((event) => {
    channel.push("sum", {number: parseInt($("#number").val())})
    $("#number").val("")
    event.preventDefault();
  });
}


export class MathController {
  static initialize(csrfToken) {initialize(csrfToken)}
}
