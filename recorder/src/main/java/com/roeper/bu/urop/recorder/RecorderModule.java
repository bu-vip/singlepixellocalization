package com.roeper.bu.urop.recorder;

import java.io.File;

import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.inject.AbstractModule;
import com.google.inject.Provides;
import com.google.inject.name.Named;
import com.roeper.bu.urop.lib.BrokerConfig;
import com.roeper.bu.urop.lib.ObjectWriter;
import com.roeper.bu.urop.lib.SensorReading;

public class RecorderModule extends AbstractModule
{
	private RecorderModuleConfig config;

	public RecorderModule(RecorderModuleConfig aConfig)
	{
		this.config = aConfig;
	}

	@Override
	protected void configure()
	{
		bind(RecorderModuleConfig.class).toInstance(this.config);
	}

	@Provides
	public MqttClient getClient()
	{
		MqttClient client = null;
		try
		{
			MemoryPersistence persistence = new MemoryPersistence();
			BrokerConfig brokerConfig = this.config.getBrokerConfig();
			String clientId = "data-recorder-" + (int) (Math.random() * 99999);
			client = new MqttClient(brokerConfig.getHostname(),
									clientId,
									persistence);
		}
		catch (MqttException e)
		{
			e.printStackTrace();
			throw new RuntimeException("Error creating MQTT client.");
		}

		return client;
	}

	@Provides
	public ObjectWriter<SensorReading> getWriter(ObjectMapper aMapper)
	{
		// create the reading writer
		String filename = "take-" + System.currentTimeMillis() + ".txt";
		String destPath = this.config.getDestinationFolder() + "/" + filename;
		File destinationFile = new File(destPath);
		// create all necessary parent folders
		if (destinationFile.getParentFile() != null)
		{
			destinationFile	.getParentFile()
							.mkdirs();
		}

		return new ObjectWriter<SensorReading>(aMapper, destinationFile);
	}
	
	@Provides
	@Named("topicPrefix")
	public String getTopicPrefix()
	{
		return this.config.getBrokerConfig().getTopicPrefix();
	}
}
