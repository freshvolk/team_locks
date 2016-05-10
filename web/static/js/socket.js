// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.
socket.connect()

let save_resource = function(resource) {
   if (localStorage) {
      let resource_list = []
      let local_list = localStorage.getItem('locks_on_locks')
      if (local_list) {
         resource_list = JSON.parse(local_list)
      }
      resource_list.push(resource)
      localStorage.setItem('locks_on_locks', JSON.stringify(resource_list))
   }
}

// Now that you are connected, you can join channels with a topic:
let join_channel = function(resource) {
   save_resource(resource)
   let lock_list = $('#locks').find('tbody')
   lock_list.append('<tr><td class="name">'+resource+'</td><td id="lock'+resource+'" class="locked">Locked</td><td><button id="changer'+resource+'">Change State</button></td></tr>')


   let channel = socket.channel("project:" + resource, {})
   channel.join()
     .receive("ok", resp => { console.log("Joined successfully", resp); change_state(resp.is_locked) })
     .receive("error", resp => { console.log("Unable to join", resp) })

   let acquire_lock = function() {
      channel.push("lock:resource:"+resource, {})
   }

   let release_lock = function() {
      channel.push("unlock:resource:"+resource, {})
   }

   let change_state = function(new_state) {
      let lock = $('#lock'+resource)
      let butt = $('#changer'+resource)
      if (new_state) {
         lock.className = "locked"
         lock.text(" Locked")
         lock.attr("class","locked")
         butt.off('click')
         butt.on('click', release_lock)
         butt.text("Release Lock")
      } else {
         lock.className = "unlocked"
         lock.text(" Free")
         lock.attr("class","unlocked")
         butt.off('click')
         butt.on('click', acquire_lock)
         butt.text("Acquire Lock")
      }
   }
   channel.on("update", payload => { console.log(payload); change_state(payload.is_locked) })
}

$('#add_resource').on('click', function() {
   join_channel($('#new_resource').val())
   $('#new_resource').val('')
})

if (localStorage && localStorage.getItem('locks_on_locks')) {
   let resources = JSON.parse(localStorage.getItem('locks_on_locks'))
   resources.forEach(function(resource) {
      join_channel(resource)
   })
}

export default socket
