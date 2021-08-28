const Admin = {
    template: `
    <div>
     
        <h1>Admin</h1>
        
        <div>
             <button id="AddNewUser" @click="exit">Exit</button>
        </div>
        
        <div class="error" v-if="validationErrors.length > 0" style = "color:red;">
            {{ validationErrors }}
        </div>
        
        <div v-for="post in users"  :key="post.id" @click="getItemByClick(post)">
           id: &nbsp;<b>{{post.id}}</b> &nbsp;&nbsp;&nbsp;&nbsp; login: &nbsp;<b>{{post.login}}</b> &nbsp;&nbsp;&nbsp;&nbsp; e-mail: &nbsp;<b>{{post.email}}</b>
        </div>
        <div>
             <button id="AddNewUser" @click="addUser">Add New User</button>
        </div>
        
         <modal v-show="userForm.display">
                
                <form @submit.prevent="" >
                      <h1>{{userForm.header}}</h1>
                      <div>
                          <label for="lgn" >Login:</label>
                          <input type="text"  name="lgn"  v-model="userForm.login" />
                      </div>
                      <div>
                          <label for="psw1" >Password-1:</label>
                          <input type="text"  name="psw1" v-model="userForm.psw1"/>
                      </div>
                      <div>
                          <label for="psw2" >Password-2:</label>
                          <input type="text"  name="psw2" v-model="userForm.psw2"/>
                      </div>
                      <div>
                          <label for="email" >E-mail:</label>
                          <input type="text"  name="email" v-model="userForm.email"/>
                      </div>
                       <div>
                          <button @click="validateAndSubmit">Save</button>
                          <button v-show="+userForm.id>0?true:false" @click="deleteUser(userForm.id)">Delete User</button>
                          <button @click="userForm.display=false">Close Window</button>
                      </div>
                 
        
                </form>
         </modal>
         
    </div>`,
    data() {
        return {
            users: [],
            validationErrors: [],

            userForm: {
                display: false,
                header: 'New User',
                lgn: '',
                psw1: '',
                psw2: '',
                email: '',
                id: 0
            }
        };
    },
    computed: {
        authstatus() {
            return this.$root.authstatus;
        },
        urls() {
            return this.$root.urls;
        },


    },
    mounted() {
        this.render();
    },

    methods: {
        async render() {


            if (!this.authstatus || !this.$root.isAdmin())
                router.push({name: 'access'});
            else {

                try {

                    const res = await axios({
                        method: 'post',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        url: this.urls.getusers,
                    });

                    const data = res.data;
                    console.log(`POST RETURN => `, data);
                    this.users = res.data.data ? res.data.data : [];

                } catch (e) {
                    console.error(e);
                }

            }
        },
        getItemByClick(post) {
            this.validationErrors = [];
            this.userForm.header = `Edit User id:${post.id}`;
            this.userForm.id = post.id;
            this.userForm.psw1 = '';
            this.userForm.psw2 = '';
            this.userForm.email = post.email;
            this.userForm.login = post.login;
            this.userForm.display = true;
        },
        addUser() {
            this.validationErrors = [];
            this.userForm.header = `Add New User`;
            this.userForm.id = 0;
            this.userForm.psw1 = '';
            this.userForm.psw2 = '';
            this.userForm.email = '';
            this.userForm.login = '';
            this.userForm.display = true;
        },
        async changeUserData() {

            try {

                const res = await axios({
                    method: 'post',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    url: this.urls.changeUserData,
                    data: {
                        id: this.userForm.id,
                        login: this.userForm.login,
                        psw: this.userForm.psw1,
                        email: this.userForm.email
                    }
                });

                const data = res.data;
                console.log(`POST RETURN => `, data);

                if (data && data.status) {
                    if (data.status == "ok") {
                        if (+this.userForm.id === 0) {
                            this.users.push(data.data[0]);
                        } else {
                            this.users.map((e) => {
                                if (e.id == data.data[0].id) {
                                    e.login = data.data[0].login;
                                    e.email = data.data[0].email;
                                }
                            });
                        }
                        this.userForm.display = false;
                    } else {
                        this.validationErrors = ['login is not unique'];
                    }
                }

            } catch (e) {
                console.error(e);
            }

        },
        async exit() {
            try {

                const res = await axios({
                    method: 'post',
                    url: this.urls.exit,
                });

                location.reload();

            } catch (e) {
                console.error(e);
            }
        },
        async deleteUser(id) {

            const res = await axios({
                method: 'post',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                url: this.urls.deleteUser,
                data: {
                    id: id,
                }
            });

            const data = res.data;
            console.log(`POST RETURN => `, data);

            if (data && data.status) {
                if (data.status == "ok") {
                    this.users.map((e, i) => {
                        if (e.id == id) this.users.splice(i, 1);
                    });
                }
            }
        },
        validateAndSubmit() {

            this.validationErrors = [];
            if (this.validate()) {
                this.changeUserData();
            }
        },
        validate() {

            const errors = [];
            const pattern = {
                email: /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
                password: /^(?=.*[0-9])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{6,16}$/
            }
            if (!pattern.email.test(this.userForm.email)) errors.push("Invalid email.");
            if (+this.userForm.id === 0 || this.userForm.psw1 !== "") {
                if (this.userForm.psw1 !== this.userForm.psw2 || !pattern.password.test(this.userForm.psw1)) errors.push("Invalid password.");
            }

            if (errors) this.validationErrors = errors;
            else this.validationErrors = [];

            return !this.validationErrors.length;
        },
    },


};
