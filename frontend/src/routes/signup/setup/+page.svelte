<script lang="ts">
import { fade } from "svelte/transition";
import { goto } from "$app/navigation";
import { page } from "$app/stores"; // Add this import
import SignInWrapper from "$lib/components/login-wrapper.svelte";
import SignupForm from "$lib/components/signup/signup-form.svelte";
import { Button } from "$lib/components/ui/button";
import { m } from "$lib/paraglide/messages";
import UserService from "$lib/services/user-service";
import WebAuthnService from "$lib/services/webauthn-service"; // Add this import
import appConfigStore from "$lib/stores/application-configuration-store";
import userStore from "$lib/stores/user-store";
import type { UserSignUp } from "$lib/types/user.type";
import { getAxiosErrorMessage } from "$lib/utils/error-util";
import { tryCatch } from "$lib/utils/try-catch-util";
import LoginLogoErrorSuccessIndicator from "../../login/components/login-logo-error-success-indicator.svelte";

const { data } = $props();
const userService = new UserService();
const webauthnService = new WebAuthnService(); // Add this

let isLoading = $state(false);
let error: string | undefined = $state();

async function handleSignup(userData: UserSignUp) {
	isLoading = true;

	const result = await tryCatch(userService.signupInitialUser(userData));

	if (result.error) {
		error = getAxiosErrorMessage(result.error);
		isLoading = false;
		return false;
	}

	await userStore.setUser(result.data);

	// Log the user out immediately after account creation
	await webauthnService.logout();

	// Now login the user (to verify email)
	goto("/login/alternative/email");

	isLoading = false;
	return true;
}
</script>

<svelte:head>
	<title>{m.signup()}</title>
</svelte:head>

<SignInWrapper>
	<div class="flex justify-center">
		<LoginLogoErrorSuccessIndicator error={!!error} />
	</div>

	<h1 class="font-playfair mt-5 text-3xl font-bold sm:text-4xl">
		{m.signup_to_appname({ appName: $appConfigStore.appName })}
	</h1>

	{#if !error}
		<p class="text-muted-foreground mt-2" in:fade>
			{m.initial_account_creation_description()}
		</p>
	{:else}
		<p class="text-muted-foreground mt-2" in:fade>
			{error}. 
		</p>
	{/if}

	<SignupForm callback={handleSignup} {isLoading} />
	<div class="mt-10 flex w-full justify-end">
		<Button type="submit" form="sign-up-form" onclick={() => (error = undefined)}
			>{m.signup()}</Button
		>
	</div>
</SignInWrapper>
