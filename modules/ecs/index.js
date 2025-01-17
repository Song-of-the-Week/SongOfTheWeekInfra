const { EC2Client, DescribeInstancesCommand, DescribeAddressesCommand, AssociateAddressCommand } = require("@aws-sdk/client-ec2");
const { AutoScalingClient, CompleteLifecycleActionCommand } = require("@aws-sdk/client-auto-scaling");

async function checkEIP(instanceId) {
    const ec2Client = new EC2Client({});
    const params = { InstanceIds: [instanceId] };
    const describeInstancesResponse = await ec2Client.send(new DescribeInstancesCommand(params));
    const instance = describeInstancesResponse.Reservations[0].Instances[0];

    // Get a list of all EIPs in your account
    const describeAddressesResponse = await ec2Client.send(new DescribeAddressesCommand({ Filters: [{ Name: 'domain', Values: ['vpc'] }] }));
    const eipSet = new Set(describeAddressesResponse.Addresses.map(addr => addr.PublicIp));

    // Check if the instance's public IP is one of your EIPs
    for (const eni of instance.NetworkInterfaces) {
        if (eni.Association && eipSet.has(eni.Association.PublicIp)) {
            console.log("Instance already has EIP:", eni.Association.PublicIp);
            return eni.Association.PublicIp;
        }
    }

    return null;
}

async function associateEIP(instanceId) {
    const ec2Client = new EC2Client({});
    // Find an available EIP
    const describeAddressesResponse = await ec2Client.send(new DescribeAddressesCommand({ Filters: [{ Name: 'domain', Values: ['vpc'] }] }));
    const availableAddress = describeAddressesResponse.Addresses.find(addr => !addr.AssociationId);

    if (!availableAddress) {
        throw new Error("No available EIP found");
    }

    // Associate the EIP with the instance
    const associateParams = {
        AllocationId: availableAddress.AllocationId,
        InstanceId: instanceId
    };
    await ec2Client.send(new AssociateAddressCommand(associateParams));
    console.log("Successfully associated EIP", availableAddress.PublicIp, "with instance", instanceId);
    return availableAddress.PublicIp;
}

function randomDelay() {
    const min = 2000;
    const max = 4000;
    const delay = Math.floor(Math.random() * (max - min + 1)) + min;
    return new Promise(resolve => setTimeout(resolve, delay));
}

exports.handler = async (event) => {
    const asClient = new AutoScalingClient({});
    const instanceId = JSON.parse(event.Records[0].Sns.Message).EC2InstanceId;
    let success = false;
    let retries = 10;  // Increased retries

    while (!success && retries > 0) {
        try {
            retries--;

            // Step 1: Check if the instance already has an EIP from your pool
            let assignedEIP = await checkEIP(instanceId);
            if (!assignedEIP) {
                // Step 2: Associate an EIP
                assignedEIP = await associateEIP(instanceId);
            }

            // Random delay between 2 and 4 seconds before verification
            await randomDelay();

            // Step 3: Verify the association
            const verifiedEIP = await checkEIP(instanceId);
            if (verifiedEIP === assignedEIP) {
                console.log("Successfully verified EIP:", verifiedEIP);
                success = true;
            } else {
                console.error("Verification failed. Retrying...");
            }
        } catch (error) {
            console.error("Error during EIP assignment:", error.message);
            if (retries === 0) {
                console.error("Max retries reached. Failing the lifecycle action.");
                const message = JSON.parse(event.Records[0].Sns.Message);
                const lifecycleParams = {
                    AutoScalingGroupName: message.AutoScalingGroupName,
                    LifecycleHookName: message.LifecycleHookName,
                    LifecycleActionToken: message.LifecycleActionToken,
                    LifecycleActionResult: "ABANDON"
                };
                await asClient.send(new CompleteLifecycleActionCommand(lifecycleParams));
                return;
            }
        }
    }

    if (success) {
        const message = JSON.parse(event.Records[0].Sns.Message);
        const lifecycleParams = {
            AutoScalingGroupName: message.AutoScalingGroupName,
            LifecycleHookName: message.LifecycleHookName,
            LifecycleActionToken: message.LifecycleActionToken,
            LifecycleActionResult: "CONTINUE"
        };
        await asClient.send(new CompleteLifecycleActionCommand(lifecycleParams));
    }
};