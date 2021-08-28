const Access = {
    template: `
    <div>

        <h1>Auth</h1>

        <form @submit.prevent="login" id="formLogin">
        
          <div>
              <label for="email" >Login:</label>
              <input type="text"  name="lgn" v-model="lgn"  :disabled="authstatus"/>
          </div>
          <div>
              <label for="email" >Password:</label>
              <input type="text"  name="psw" v-model="psw"  :disabled="authstatus"/>
              <button type="submit" :disabled="authstatus">Access</button>
          </div>

          <div>
              <i v-if="authstatus">You have access! </i>
          </div>

        </form>
    </div>`,

    data() {
        return {
            lgn: "",
            psw: "",
        };
    },
    computed: {
        authstatus() {
            // this way of sharing values is ok for small projects.
            // large projects must use Vuex
            return this.$root.authstatus;
        },

        urls() {
            // fetch URLs from root
            return this.$root.urls;
        },
    },
    mounted() {
        this.login();
    },
    methods: {

        async login() {
            try {

                const res = await axios({
                    method: 'post',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    url: this.urls.authpost,
                    data: {
                        login: this.lgn,
                        psw: this.psw
                    }
                });

                const data = res.data;

                console.log(`POST RETURN => `, data);
                if (data && data.status && data.status == "ok") {
                    this.$emit("auth-verified", {status: true, user: data.data});
                }
            } catch (e) {
                console.error(e);
            }


        },

    },
};
