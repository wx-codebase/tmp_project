const User = {
    template: `

        <div>
            <h1>User</h1>
            <div>ID = {{this.$root.user.id}} ROLES = {{this.$root.user.roles}}</div>
            <button  @click="exit">Exit</button>
        </div>
        
        `,

    data() {
        return {};
    },
    computed:{
        urls() {
            // fetch URLs from root
            return this.$root.urls;
        },
    },
    mounted() {
        this.render();
    },
    methods:{
        render()
        {
            if (!this.$root.authstatus) {
                router.push({name: 'access'});
            }
        },
        async exit()
        {
            try {

                const res = await axios({
                    method: 'post',
                    url: this.urls.exit,
                });

                location.reload();

            } catch (e) {
                console.error(e);
            }
        }
    }

};
